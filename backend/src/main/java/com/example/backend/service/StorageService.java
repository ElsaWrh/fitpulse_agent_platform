package com.example.backend.service;

import com.example.backend.config.MinioConfig;
import com.example.backend.exception.BusinessException;
import io.minio.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.UUID;

/**
 * 存储服务 - 处理文件上传到 MinIO
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class StorageService {

    private final MinioClient minioClient;
    private final MinioConfig minioConfig;

    /**
     * 上传图片到 MinIO
     *
     * @param file   上传的文件
     * @param folder 存储文件夹
     * @return 图片访问 URL
     */
    public String uploadImage(MultipartFile file, String folder) {
        try {
            // 确保 bucket 存在
            ensureBucketExists();

            // 生成唯一文件名
            String filename = UUID.randomUUID().toString() +
                    getFileExtension(file.getOriginalFilename());
            String objectName = folder + "/" + filename;

            // 上传文件
            try (InputStream inputStream = file.getInputStream()) {
                minioClient.putObject(
                        PutObjectArgs.builder()
                                .bucket(minioConfig.getBucketName())
                                .object(objectName)
                                .stream(inputStream, file.getSize(), -1)
                                .contentType(file.getContentType())
                                .build());
            }

            log.info("文件上传成功: {}", objectName);
            return getFileUrl(objectName);

        } catch (Exception e) {
            log.error("文件上传失败", e);
            throw new BusinessException(5000, "文件上传失败: " + e.getMessage());
        }
    }

    /**
     * 确保 bucket 存在,不存在则创建
     */
    private void ensureBucketExists() throws Exception {
        boolean exists = minioClient.bucketExists(
                BucketExistsArgs.builder()
                        .bucket(minioConfig.getBucketName())
                        .build());

        if (!exists) {
            minioClient.makeBucket(
                    MakeBucketArgs.builder()
                            .bucket(minioConfig.getBucketName())
                            .build());
            log.info("创建 bucket: {}", minioConfig.getBucketName());
        }
    }

    /**
     * 获取文件访问 URL
     */
    private String getFileUrl(String objectName) {
        return minioConfig.getEndpoint() + "/" +
                minioConfig.getBucketName() + "/" + objectName;
    }

    /**
     * 获取文件扩展名
     */
    private String getFileExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return "";
        }
        return filename.substring(filename.lastIndexOf("."));
    }

    /**
     * 验证文件是否为图片
     */
    public boolean isValidImage(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return false;
        }

        String contentType = file.getContentType();
        if (contentType == null) {
            return false;
        }

        return contentType.startsWith("image/");
    }

    /**
     * 验证文件大小
     */
    public boolean isValidSize(MultipartFile file, long maxSizeInBytes) {
        return file != null && file.getSize() <= maxSizeInBytes;
    }
}
