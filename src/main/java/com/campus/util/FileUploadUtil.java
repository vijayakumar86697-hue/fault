package com.campus.util;

import com.campus.config.AppConfig;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

/**
 * Utility for handling secure file uploads (fault photographs, repair evidence).
 */
public class FileUploadUtil {
    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList(".jpg", ".jpeg", ".png", ".webp", ".gif", ".pdf");
    private static final List<String> ALLOWED_MIME_TYPES = Arrays.asList(
        "image/jpeg", "image/png", "image/webp", "image/gif", "application/pdf"
    );

    private FileUploadUtil() {}

    /**
     * Validates and saves an uploaded Part to disk.
     * @param part The uploaded multipart Part
     * @param uploadBaseDir Base directory where files are saved
     * @return UploadResult containing metadata or throws IllegalArgumentException
     */
    public static UploadResult saveFile(Part part, String uploadBaseDir) throws IOException {
        if (part == null || part.getSize() == 0) {
            throw new IllegalArgumentException("No file provided");
        }

        long maxSize = AppConfig.getMaxFileSize();
        if (part.getSize() > maxSize) {
            throw new IllegalArgumentException("File size exceeds maximum allowed limit of " + (maxSize / (1024 * 1024)) + "MB");
        }

        String submittedFilename = part.getSubmittedFileName();
        if (submittedFilename == null || submittedFilename.isBlank()) {
            throw new IllegalArgumentException("Invalid filename");
        }

        String sanitizedOriginalName = SecurityUtil.sanitizeFilename(submittedFilename);
        String extension = "";
        int dotIdx = sanitizedOriginalName.lastIndexOf('.');
        if (dotIdx >= 0) {
            extension = sanitizedOriginalName.substring(dotIdx).toLowerCase();
        }

        if (!ALLOWED_EXTENSIONS.contains(extension)) {
            throw new IllegalArgumentException("Unsupported file extension. Allowed: " + String.join(", ", ALLOWED_EXTENSIONS));
        }

        String mimeType = part.getContentType();
        if (mimeType == null || !ALLOWED_MIME_TYPES.contains(mimeType.toLowerCase())) {
            throw new IllegalArgumentException("Invalid file type: " + mimeType);
        }

        // Generate unique name to prevent collisions and directory traversal
        String storedName = UUID.randomUUID().toString() + extension;
        File uploadDir = new File(uploadBaseDir);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        Path targetPath = new File(uploadDir, storedName).toPath();
        try (InputStream in = part.getInputStream()) {
            Files.copy(in, targetPath, StandardCopyOption.REPLACE_EXISTING);
        }

        return new UploadResult(sanitizedOriginalName, storedName, storedName, part.getSize(), mimeType);
    }

    /**
     * Validates and saves an uploaded Spring MultipartFile to disk.
     */
    public static UploadResult saveMultipartFile(org.springframework.web.multipart.MultipartFile file, String uploadBaseDir) throws IOException {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("No file provided");
        }

        long maxSize = AppConfig.getMaxFileSize();
        if (file.getSize() > maxSize) {
            throw new IllegalArgumentException("File size exceeds maximum allowed limit of " + (maxSize / (1024 * 1024)) + "MB");
        }

        String submittedFilename = file.getOriginalFilename();
        if (submittedFilename == null || submittedFilename.isBlank()) {
            throw new IllegalArgumentException("Invalid filename");
        }

        String sanitizedOriginalName = SecurityUtil.sanitizeFilename(submittedFilename);
        String extension = "";
        int dotIdx = sanitizedOriginalName.lastIndexOf('.');
        if (dotIdx >= 0) {
            extension = sanitizedOriginalName.substring(dotIdx).toLowerCase();
        }

        if (!ALLOWED_EXTENSIONS.contains(extension)) {
            throw new IllegalArgumentException("Unsupported file extension. Allowed: " + String.join(", ", ALLOWED_EXTENSIONS));
        }

        String mimeType = file.getContentType();
        if (mimeType == null || !ALLOWED_MIME_TYPES.contains(mimeType.toLowerCase())) {
            throw new IllegalArgumentException("Invalid file type: " + mimeType);
        }

        String storedName = UUID.randomUUID().toString() + extension;
        File uploadDir = new File(uploadBaseDir);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        Path targetPath = new File(uploadDir, storedName).toPath();
        try (InputStream in = file.getInputStream()) {
            Files.copy(in, targetPath, StandardCopyOption.REPLACE_EXISTING);
        }

        return new UploadResult(sanitizedOriginalName, storedName, storedName, file.getSize(), mimeType);
    }

    public static class UploadResult {
        private final String originalName;
        private final String storedName;
        private final String relativePath;
        private final long size;
        private final String mimeType;

        public UploadResult(String originalName, String storedName, String relativePath, long size, String mimeType) {
            this.originalName = originalName;
            this.storedName = storedName;
            this.relativePath = relativePath;
            this.size = size;
            this.mimeType = mimeType;
        }

        public String getOriginalName() { return originalName; }
        public String getStoredName() { return storedName; }
        public String getRelativePath() { return relativePath; }
        public long getSize() { return size; }
        public String getMimeType() { return mimeType; }
    }
}
