package com.brainboxemb.tool.fixture;

/** Minimal runnable Java 8 fixture for reusable toolchain verification. */
public final class App {
    private App() {
    }

    public static String message() {
        return "tool.java-project fixture OK";
    }

    public static void main(String[] args) {
        System.out.println(message());
    }
}
