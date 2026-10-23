package com.campus.service;

import com.campus.util.FileUploadUtil;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

/**
 * Spring Service managing file storage and validation for attachments.
 */
@Service
public class StorageService {

    @Value("${upload.directory:uploads}")
    private String uploadDirectory;

    public FileUploadUtil.UploadResult store(MultipartFile file) throws IOException {
        return FileUploadUtil.saveMultipartFile(file, uploadDirectory);
    }

    public FileUploadUtil.UploadResult store(MultipartFile file, String customDir) throws IOException {
        String targetDir = (customDir != null && !customDir.isBlank()) ? customDir : uploadDirectory;
        return FileUploadUtil.saveMultipartFile(file, targetDir);
    }

    public String getUploadDirectory() {
        return uploadDirectory;
    }
}
