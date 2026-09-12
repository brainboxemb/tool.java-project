# Minimal Java fixture

This is a deliberately domain-free Java 8 application used only to prove `tool.java-project`.

It must remain small enough that a toolchain failure is not confused with product complexity.

Expected local commands:

```text
Linux/macOS: ./mvnw verify
Windows:     mvnw.cmd verify
```

The resulting runnable artifact is:

```text
target/minimal-java-app-0.1.0-SNAPSHOT.jar
```

Expected output:

```text
tool.java-project fixture OK
```
