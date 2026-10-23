package com.campus;

import org.junit.jupiter.api.Test;

import java.net.CookieManager;
import java.net.CookiePolicy;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

public class IntegrationFlowTest {

    private static final String BASE_URL = "http://localhost:8080/campus-fault-system";

    private HttpClient createClient() {
        CookieManager cookieManager = new CookieManager(null, CookiePolicy.ACCEPT_ALL);
        return HttpClient.newBuilder()
                .cookieHandler(cookieManager)
                .followRedirects(HttpClient.Redirect.ALWAYS)
                .build();
    }

    private String buildFormData(Map<String, String> data) {
        StringBuilder builder = new StringBuilder();
        for (Map.Entry<String, String> entry : data.entrySet()) {
            if (builder.length() > 0) {
                builder.append("&");
            }
            builder.append(URLEncoder.encode(entry.getKey(), StandardCharsets.UTF_8));
            builder.append("=");
            builder.append(URLEncoder.encode(entry.getValue(), StandardCharsets.UTF_8));
        }
        return builder.toString();
    }

    @Test
    public void testLoginPageRenders() throws Exception {
        HttpClient client = createClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/auth/login"))
                .GET()
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, response.statusCode());
        assertTrue(response.body().contains("Campus Infrastructure Portal"));
        assertTrue(response.body().contains("Sign In"));
    }

    @Test
    public void testAdminLoginAndDashboard() throws Exception {
        HttpClient client = createClient();

        String formData = buildFormData(Map.of(
                "username", "admin",
                "password", "admin123"
        ));

        HttpRequest loginReq = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/auth/login"))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(formData))
                .build();

        HttpResponse<String> loginResp = client.send(loginReq, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, loginResp.statusCode());
        assertTrue(loginResp.body().contains("Campus Operations Dashboard"), "Should render Admin dashboard");
        assertTrue(loginResp.body().contains("Total Complaints"));
        assertTrue(loginResp.body().contains("CMP-2026-0001"));
    }

    @Test
    public void testStudentLoginAndDashboard() throws Exception {
        HttpClient client = createClient();

        String formData = buildFormData(Map.of(
                "username", "student1",
                "password", "student123"
        ));

        HttpRequest loginReq = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/auth/login"))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(formData))
                .build();

        HttpResponse<String> loginResp = client.send(loginReq, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, loginResp.statusCode());
        assertTrue(loginResp.body().contains("Welcome back"), "Should render Student dashboard");
        assertTrue(loginResp.body().contains("Report Infrastructure Fault"));
    }

    @Test
    public void testWorkerLoginAndDashboard() throws Exception {
        HttpClient client = createClient();

        String formData = buildFormData(Map.of(
                "username", "worker_elec",
                "password", "worker123"
        ));

        HttpRequest loginReq = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/auth/login"))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(formData))
                .build();

        HttpResponse<String> loginResp = client.send(loginReq, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, loginResp.statusCode());
        assertTrue(loginResp.body().contains("Maintenance Technician Console"), "Should render Worker dashboard");
        assertTrue(loginResp.body().contains("My Active Work Queue"));
    }

    @Test
    public void testRoleBasedAccessControlRestriction() throws Exception {
        HttpClient studentClient = createClient();

        // 1. Log in as Student
        String formData = buildFormData(Map.of(
                "username", "student1",
                "password", "student123"
        ));
        HttpRequest loginReq = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/auth/login"))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(formData))
                .build();
        studentClient.send(loginReq, HttpResponse.BodyHandlers.ofString());

        // 2. Student attempts to access Admin Complaints Console directly
        HttpRequest forbiddenReq = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/admin/complaints"))
                .GET()
                .build();

        HttpResponse<String> forbiddenResp = studentClient.send(forbiddenReq, HttpResponse.BodyHandlers.ofString());
        assertEquals(403, forbiddenResp.statusCode(), "Student must be rejected with 403 Forbidden on admin routes");
    }
}
