package com.campus;

import java.io.File;
import java.io.FileWriter;
import java.net.CookieManager;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

public class PageCaptureHelper {

    private static final String BASE_URL = "http://localhost:8080/campus-fault-system";
    private static final String OUTPUT_DIR = "d:/temp_screenshots";

    public static void main(String[] args) throws Exception {
        new File(OUTPUT_DIR).mkdirs();

        // 1. Capture Admin Extras
        captureRolePages("admin", "admin123", new String[][]{
            {"/admin/categories/list", "11_admin_categories.html"},
            {"/admin/buildings/list", "12_admin_buildings.html"},
            {"/admin/users/list", "13_admin_users.html"}
        });

        // 2. Capture Student Complaint Submit Form
        captureRolePages("student1", "student123", new String[][]{
            {"/complaints/new", "10_submit_fault_form.html"}
        });

        System.out.println("EXTRAS_DOWNLOADED_SUCCESSFULLY");
    }

    private static void captureRolePages(String username, String password, String[][] pages) throws Exception {
        CookieManager cookieManager = new CookieManager();
        HttpClient client = HttpClient.newBuilder()
                .cookieHandler(cookieManager)
                .followRedirects(HttpClient.Redirect.ALWAYS)
                .build();

        // Login POST
        String formBody = "username=" + username + "&password=" + password;
        HttpRequest loginReq = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/auth/login"))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(formBody, StandardCharsets.UTF_8))
                .build();

        client.send(loginReq, HttpResponse.BodyHandlers.ofString());

        // Fetch each page
        for (String[] page : pages) {
            String path = page[0];
            String filename = page[1];

            HttpRequest getReq = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + path))
                    .GET()
                    .build();

            HttpResponse<String> resp = client.send(getReq, HttpResponse.BodyHandlers.ofString());
            String html = resp.body();

            // Inject base tag
            String baseTag = "<base href=\"" + BASE_URL + "/\">";
            if (html.contains("<head>")) {
                html = html.replace("<head>", "<head>\n    " + baseTag);
            }

            File outFile = new File(OUTPUT_DIR, filename);
            try (FileWriter writer = new FileWriter(outFile, StandardCharsets.UTF_8)) {
                writer.write(html);
            }
            System.out.println("Saved " + filename + " (" + outFile.length() + " bytes)");
        }
    }
}
