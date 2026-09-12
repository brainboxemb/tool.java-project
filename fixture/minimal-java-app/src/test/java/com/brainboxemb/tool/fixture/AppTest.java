package com.brainboxemb.tool.fixture;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class AppTest {
    @Test
    public void exposesExpectedMessage() {
        assertEquals("tool.java-project fixture OK", App.message());
    }
}
