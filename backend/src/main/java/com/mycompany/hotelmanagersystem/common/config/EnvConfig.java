package com.mycompany.hotelmanagersystem.common.config;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public final class EnvConfig {

    private static final Map<String, String> ENV_VARS = new HashMap<>();

    static {
        loadDotEnv();
    }

    private EnvConfig() {
    }

    private static void loadDotEnv() {
        File[] candidatePaths = {
                new File(".env"),
                new File("..", ".env"),
                new File(System.getProperty("user.dir"), ".env"),
                new File(System.getProperty("user.dir"), "../.env")
        };

        for (File envFile : candidatePaths) {
            if (envFile.exists() && envFile.isFile()) {
                loadFile(envFile);
                return;
            }
        }

        loadFromClasspath();
    }

    private static void loadFile(File file) {
        try (BufferedReader reader = new BufferedReader(new FileReader(file, StandardCharsets.UTF_8))) {
            parseLines(reader);
        } catch (IOException e) {
            System.err.println("EnvConfig: Không thể đọc file .env từ đĩa: " + e.getMessage());
        }
    }

    private static void loadFromClasspath() {
        ClassLoader cl = EnvConfig.class.getClassLoader();
        InputStream is = (cl != null) ? cl.getResourceAsStream(".env") : null;
        if (is != null) {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                parseLines(reader);
            } catch (IOException e) {
                System.err.println("EnvConfig: Không thể đọc .env từ classpath: " + e.getMessage());
            }
        }
    }

    private static void parseLines(BufferedReader reader) throws IOException {
        String line;
        while ((line = reader.readLine()) != null) {
            String trimmed = line.trim();
            if (trimmed.isEmpty() || trimmed.startsWith("#") || !trimmed.contains("=")) {
                continue;
            }
            int idx = trimmed.indexOf('=');
            String key = trimmed.substring(0, idx).trim();
            String value = trimmed.substring(idx + 1).trim();
            if ((value.startsWith("\"") && value.endsWith("\""))
                    || (value.startsWith("'") && value.endsWith("'"))) {
                value = value.substring(1, value.length() - 1);
            }
            ENV_VARS.put(key, value);
        }
    }

    public static String get(String key, String defaultValue) {
        String val = ENV_VARS.get(key);
        if (val == null || val.trim().isEmpty()) {
            val = System.getenv(key);
        }
        return (val != null && !val.trim().isEmpty()) ? val.trim() : defaultValue;
    }

    public static String get(String key) {
        return get(key, "");
    }
}
