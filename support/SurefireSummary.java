import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/** Generate a deterministic human-readable summary from Maven Surefire XML. */
public final class SurefireSummary {
    private static final class Suite {
        String module;
        String name;
        int tests;
        int failures;
        int errors;
        int skipped;
        double time;
        String raw;
    }

    private static final class Problem {
        String kind;
        String module;
        String suite;
        String test;
        String message;
    }

    private static final class Totals {
        int tests;
        int failures;
        int errors;
        int skipped;
        double time;

        void add(Suite suite) {
            tests += suite.tests;
            failures += suite.failures;
            errors += suite.errors;
            skipped += suite.skipped;
            time += suite.time;
        }
    }

    private SurefireSummary() {
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("Usage: SurefireSummary <report-root> <output.md>");
            System.exit(2);
        }

        Path reportRoot = Paths.get(args[0]).toAbsolutePath().normalize();
        Path output = Paths.get(args[1]).toAbsolutePath().normalize();
        List<Path> xmlFiles = new ArrayList<Path>();
        if (Files.isDirectory(reportRoot)) {
            Files.walk(reportRoot)
                .filter(path -> Files.isRegularFile(path))
                .filter(path -> path.getFileName().toString().startsWith("TEST-"))
                .filter(path -> path.getFileName().toString().endsWith(".xml"))
                .forEach(xmlFiles::add);
        }
        Collections.sort(xmlFiles);

        List<Suite> suites = new ArrayList<Suite>();
        List<Problem> problems = new ArrayList<Problem>();
        for (Path xml : xmlFiles) {
            parseFile(reportRoot, xml, suites, problems);
        }
        Collections.sort(suites, Comparator
            .comparing((Suite suite) -> suite.module)
            .thenComparing(suite -> suite.name)
            .thenComparing(suite -> suite.raw));

        Totals totals = new Totals();
        Map<String, Totals> modules = new LinkedHashMap<String, Totals>();
        for (Suite suite : suites) {
            totals.add(suite);
            Totals module = modules.get(suite.module);
            if (module == null) {
                module = new Totals();
                modules.put(suite.module, module);
            }
            module.add(suite);
        }

        List<String> lines = new ArrayList<String>();
        lines.add("# Unit test report");
        lines.add("");
        lines.add("Generated from the Maven Surefire XML produced by the canonical `mvn verify` run. Tests are **not** rerun to create this report.");
        lines.add("");

        if (suites.isEmpty()) {
            lines.add("No Surefire `TEST-*.xml` files were found in the configured test-report path.");
            lines.add("");
        } else {
            String status = totals.failures == 0 && totals.errors == 0 ? "PASS" : "FAIL";
            lines.add("## Summary");
            lines.add("");
            lines.add("**Status: " + status + "**");
            lines.add("");
            lines.add("| Tests | Failures | Errors | Skipped | Time (s) |");
            lines.add("| ---: | ---: | ---: | ---: | ---: |");
            lines.add(String.format(java.util.Locale.ROOT, "| %d | %d | %d | %d | %.3f |",
                totals.tests, totals.failures, totals.errors, totals.skipped, totals.time));
            lines.add("");
            lines.add("## Maven modules");
            lines.add("");
            lines.add("| Module | Tests | Failures | Errors | Skipped | Time (s) |");
            lines.add("| --- | ---: | ---: | ---: | ---: | ---: |");
            for (Map.Entry<String, Totals> entry : modules.entrySet()) {
                Totals row = entry.getValue();
                lines.add(String.format(java.util.Locale.ROOT, "| `%s` | %d | %d | %d | %d | %.3f |",
                    md(entry.getKey()), row.tests, row.failures, row.errors, row.skipped, row.time));
            }
            lines.add("");
            lines.add("## Test suites");
            lines.add("");
            lines.add("| Module | Suite | Tests | Failures | Errors | Skipped | Time (s) | Raw XML |");
            lines.add("| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |");
            for (Suite suite : suites) {
                lines.add(String.format(java.util.Locale.ROOT,
                    "| `%s` | `%s` | %d | %d | %d | %d | %.3f | [XML](%s) |",
                    md(suite.module), md(suite.name), suite.tests, suite.failures, suite.errors,
                    suite.skipped, suite.time, suite.raw));
            }
            lines.add("");
            lines.add("## Failures and errors");
            lines.add("");
            if (problems.isEmpty()) {
                lines.add("None.");
            } else {
                for (Problem problem : problems) {
                    lines.add("- **" + problem.kind.toUpperCase(java.util.Locale.ROOT) + "** `"
                        + md(problem.module) + "` / `" + md(problem.suite) + "` / `"
                        + md(problem.test) + "` — " + md(problem.message));
                }
            }
            lines.add("");
            lines.add("## Raw evidence");
            lines.add("");
            lines.add("The original Surefire XML/TXT files are retained below this directory for detailed inspection.");
            lines.add("");
        }

        Files.createDirectories(output.getParent());
        Files.write(output, String.join("\n", lines).getBytes(StandardCharsets.UTF_8));
    }

    private static void parseFile(Path reportRoot, Path xml, List<Suite> suites, List<Problem> problems) throws Exception {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setNamespaceAware(false);
        factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
        Document document = factory.newDocumentBuilder().parse(xml.toFile());
        Element root = document.getDocumentElement();
        List<Element> suiteElements = new ArrayList<Element>();
        if ("testsuite".equals(root.getTagName())) {
            suiteElements.add(root);
        } else {
            NodeList nodes = root.getElementsByTagName("testsuite");
            for (int i = 0; i < nodes.getLength(); i++) {
                Node node = nodes.item(i);
                if (node instanceof Element) {
                    suiteElements.add((Element) node);
                }
            }
        }

        for (Element element : suiteElements) {
            Suite suite = new Suite();
            suite.module = moduleName(reportRoot.relativize(xml));
            suite.name = value(element, "name", xml.getFileName().toString());
            suite.tests = integer(element, "tests");
            suite.failures = integer(element, "failures");
            suite.errors = integer(element, "errors");
            suite.skipped = integer(element, "skipped");
            suite.time = decimal(element, "time");
            suite.raw = reportRoot.relativize(xml).toString().replace('\\', '/');
            suites.add(suite);

            NodeList cases = element.getElementsByTagName("testcase");
            for (int i = 0; i < cases.getLength(); i++) {
                Element testCase = (Element) cases.item(i);
                collectProblems(suite, testCase, "failure", problems);
                collectProblems(suite, testCase, "error", problems);
            }
        }
    }

    private static void collectProblems(Suite suite, Element testCase, String kind, List<Problem> problems) {
        NodeList details = testCase.getElementsByTagName(kind);
        for (int i = 0; i < details.getLength(); i++) {
            Element detail = (Element) details.item(i);
            Problem problem = new Problem();
            problem.kind = kind;
            problem.module = suite.module;
            problem.suite = suite.name;
            problem.test = value(testCase, "name", "(unnamed)");
            String message = value(detail, "message", "");
            if (message.isEmpty()) {
                message = detail.getTextContent() == null ? "" : detail.getTextContent().trim();
            }
            problem.message = message.isEmpty() ? "no message" : message;
            problems.add(problem);
        }
    }

    private static String moduleName(Path relative) {
        int targetIndex = -1;
        for (int i = 0; i < relative.getNameCount(); i++) {
            if ("target".equals(relative.getName(i).toString())) {
                targetIndex = i;
                break;
            }
        }
        if (targetIndex <= 0) {
            return "(root)";
        }
        StringBuilder result = new StringBuilder();
        for (int i = 0; i < targetIndex; i++) {
            if (result.length() > 0) {
                result.append('/');
            }
            result.append(relative.getName(i).toString());
        }
        return result.length() == 0 ? "(root)" : result.toString();
    }

    private static int integer(Element element, String attribute) {
        try {
            return Integer.parseInt(element.getAttribute(attribute));
        } catch (NumberFormatException ignored) {
            return 0;
        }
    }

    private static double decimal(Element element, String attribute) {
        try {
            return Double.parseDouble(element.getAttribute(attribute));
        } catch (NumberFormatException ignored) {
            return 0.0;
        }
    }

    private static String value(Element element, String attribute, String fallback) {
        String value = element.getAttribute(attribute);
        return value == null || value.isEmpty() ? fallback : value;
    }

    private static String md(String value) {
        return value.replace("|", "\\|").replaceAll("\\s+", " ").trim();
    }
}
