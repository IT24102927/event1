package com.photobooking.util;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;
import java.util.logging.Logger;
import java.util.logging.Level;
import javax.servlet.ServletContext;

/**
 * Comprehensive File Handling Utility for the Event Photography System
 * Provides robust methods for file operations with extensive error handling
 */
public class FileHandler {
    private static final Logger LOGGER = Logger.getLogger(FileHandler.class.getName());
    private static String DATA_DIRECTORY = "WEB-INF/data";
    private static boolean initialized = false;
    private static ServletContext servletContext = null;

    // Prevent instantiation
    private FileHandler() {
        throw new AssertionError("Cannot be instantiated");
    }

    /**
     * Set the ServletContext for proper file path resolution
     * @param context the ServletContext
     */
    public static void setServletContext(ServletContext context) {
        servletContext = context;
        initialize();
    }

    /**
     * Initialize and ensure data directory exists
     */
    public static synchronized void initialize() {
        if (initialized) {
            return;
        }

        try {
            // If running in a web context and servletContext is available
            if (servletContext != null) {
                // Get the real path to the data directory
                String realPath = servletContext.getRealPath("/" + DATA_DIRECTORY);

                if (realPath != null) {
                    DATA_DIRECTORY = realPath;
                    File directory = new File(DATA_DIRECTORY);

                    if (!directory.exists()) {
                        boolean created = directory.mkdirs();
                        if (created) {
                            LOGGER.info("Created data directory: " + directory.getAbsolutePath());
                        } else {
                            LOGGER.warning("Failed to create data directory: " + directory.getAbsolutePath());
                        }
                    } else {
                        LOGGER.info("Using existing data directory: " + directory.getAbsolutePath());
                    }
                } else {
                    // Fallback for development environment
                    String userDir = System.getProperty("user.dir");
                    DATA_DIRECTORY = userDir + File.separator + "src" + File.separator + "main" +
                            File.separator + "webapp" + File.separator + "WEB-INF" +
                            File.separator + "data";

                    File directory = new File(DATA_DIRECTORY);
                    if (!directory.exists()) {
                        boolean created = directory.mkdirs();
                        if (created) {
                            LOGGER.info("Created fallback data directory: " + directory.getAbsolutePath());
                        } else {
                            LOGGER.warning("Failed to create fallback data directory: " + directory.getAbsolutePath());
                        }
                    }
                    LOGGER.info("Using fallback data directory: " + directory.getAbsolutePath());
                }
            } else {
                // When running outside a web context (e.g. unit tests)
                String userDir = System.getProperty("user.dir");
                DATA_DIRECTORY = userDir + File.separator + "src" + File.separator + "main" +
                        File.separator + "webapp" + File.separator + "WEB-INF" +
                        File.separator + "data";

                File directory = new File(DATA_DIRECTORY);
                if (!directory.exists()) {
                    boolean created = directory.mkdirs();
                    if (created) {
                        LOGGER.info("Created standalone data directory: " + directory.getAbsolutePath());
                    } else {
                        LOGGER.warning("Failed to create standalone data directory: " + directory.getAbsolutePath());
                    }
                }
                LOGGER.info("Using standalone data directory: " + directory.getAbsolutePath());
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error initializing data directory", e);
            // Create a fallback directory in the current working directory
            String userDir = System.getProperty("user.dir");
            DATA_DIRECTORY = userDir + File.separator + "data";

            File directory = new File(DATA_DIRECTORY);
            if (!directory.exists()) {
                directory.mkdirs();
            }
            LOGGER.info("Using emergency fallback data directory: " + directory.getAbsolutePath());
        }

        initialized = true;
        LOGGER.info("FileHandler initialized with data directory: " + DATA_DIRECTORY);
    }

    /**
     * Creates a directory if it doesn't exist
     * @param directoryPath Path of the directory to create
     * @return true if directory exists or was created successfully
     */
    public static boolean createDirectory(String directoryPath) {
        initialize();

        // Determine the full path
        String fullPath;
        File dataDir = new File(DATA_DIRECTORY);

        if (directoryPath.startsWith(dataDir.getAbsolutePath()) || new File(directoryPath).isAbsolute()) {
            fullPath = directoryPath;
        } else {
            fullPath = DATA_DIRECTORY + File.separator + directoryPath;
        }

        File directory = new File(fullPath);
        if (!directory.exists()) {
            boolean created = directory.mkdirs();
            if (created) {
                LOGGER.info("Created directory: " + directory.getAbsolutePath());
            } else {
                LOGGER.warning("Failed to create directory: " + directory.getAbsolutePath());
            }
            return created;
        }
        return true;
    }

    /**
     * Checks if a file exists
     * @param filePath Path to the file
     * @return true if file exists, false otherwise
     */
    public static boolean fileExists(String filePath) {
        initialize();

        String fullPath = getFullPath(filePath);
        boolean exists = new File(fullPath).exists();
        return exists;
    }

    /**
     * Ensures a file exists, creating it if necessary
     * @param filePath Path to the file
     * @return true if file exists or was created successfully
     */
    public static boolean ensureFileExists(String filePath) {
        try {
            initialize();

            String fullPath = getFullPath(filePath);

            File file = new File(fullPath);

            // Create parent directory if it doesn't exist
            if (file.getParentFile() != null && !file.getParentFile().exists()) {
                boolean dirCreated = file.getParentFile().mkdirs();
                if (dirCreated) {
                    LOGGER.info("Created directory: " + file.getParentFile().getAbsolutePath());
                } else {
                    LOGGER.warning("Could not create directory: " + file.getParentFile().getAbsolutePath());
                    return false;
                }
            }

            // Create file if it doesn't exist
            if (!file.exists()) {
                boolean created = file.createNewFile();
                if (created) {
                    LOGGER.info("Created new file: " + filePath);
                } else {
                    LOGGER.warning("Could not create file: " + filePath);
                }
                return created;
            }
            return true;
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Error ensuring file exists: " + filePath, e);
            return false;
        }
    }

    /**
     * Writes content to a file
     * @param filePath Path to the file
     * @param content Content to write
     * @param append Whether to append or overwrite
     * @return true if write was successful
     */
    public static boolean writeToFile(String filePath, String content, boolean append) {
        try {
            initialize();

            String fullPath = getFullPath(filePath);

            // Ensure file exists
            if (!ensureFileExists(fullPath)) {
                LOGGER.warning("Could not create file: " + filePath);
                return false;
            }

            // Write content
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(fullPath, append))) {
                writer.write(content);
            }

            LOGGER.info("Successfully wrote to file: " + filePath);
            return true;
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Error writing to file: " + filePath, e);
            return false;
        }
    }

    /**
     * Reads all lines from a file
     * @param filePath Path to the file
     * @return List of lines, empty list if file doesn't exist or error occurs
     */
    public static List<String> readLines(String filePath) {
        List<String> lines = new ArrayList<>();

        try {
            initialize();

            String fullPath = getFullPath(filePath);
            File file = new File(fullPath);

            // Check if file exists
            if (!file.exists()) {
                // Create the file if it doesn't exist
                ensureFileExists(fullPath);
                return lines; // Return empty list for newly created file
            }

            try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    lines.add(line);
                }
            }
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Error reading file: " + filePath, e);
        }

        return lines;
    }

    /**
     * Reads entire file content as a string
     * @param filePath Path to the file
     * @return File content as string, empty string if error occurs
     */
    public static String readFileContent(String filePath) {
        try {
            initialize();

            String fullPath = getFullPath(filePath);
            File file = new File(fullPath);

            // Check if file exists
            if (!file.exists()) {
                ensureFileExists(fullPath);
                return "";
            }

            // Read all bytes
            byte[] bytes = new byte[(int) file.length()];
            try (FileInputStream fis = new FileInputStream(file)) {
                fis.read(bytes);
            }

            return new String(bytes, StandardCharsets.UTF_8);
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Error reading file content: " + filePath, e);
            return "";
        }
    }

    /**
     * Appends a line to a file
     * @param filePath Path to the file
     * @param line Line to append
     * @return true if successful, false otherwise
     */
    public static boolean appendLine(String filePath, String line) {
        return writeToFile(filePath, line + System.lineSeparator(), true);
    }

    /**
     * Deletes a file
     * @param filePath Path to the file
     * @return true if file was deleted or didn't exist
     */
    public static boolean deleteFile(String filePath) {
        initialize();

        String fullPath = getFullPath(filePath);
        File file = new File(fullPath);

        if (!file.exists()) {
            LOGGER.info("File does not exist: " + filePath);
            return true;
        }

        boolean deleted = file.delete();
        if (deleted) {
            LOGGER.info("Successfully deleted file: " + filePath);
        } else {
            LOGGER.warning("Failed to delete file: " + filePath);
        }

        return deleted;
    }

    /**
     * Copies a file from one location to another
     * @param sourcePath Source file path
     * @param destinationPath Destination file path
     * @return true if copy was successful, false otherwise
     */
    public static boolean copyFile(String sourcePath, String destinationPath) {
        try {
            initialize();

            String fullSourcePath = getFullPath(sourcePath);
            String fullDestPath = getFullPath(destinationPath);

            File sourceFile = new File(fullSourcePath);
            File destFile = new File(fullDestPath);

            // Ensure source file exists
            if (!sourceFile.exists()) {
                LOGGER.warning("Source file does not exist: " + sourcePath);
                return false;
            }

            // Ensure destination directory exists
            if (destFile.getParentFile() != null && !destFile.getParentFile().exists()) {
                destFile.getParentFile().mkdirs();
            }

            try (
                    FileInputStream inputStream = new FileInputStream(sourceFile);
                    FileOutputStream outputStream = new FileOutputStream(destFile)
            ) {
                byte[] buffer = new byte[1024];
                int length;
                while ((length = inputStream.read(buffer)) > 0) {
                    outputStream.write(buffer, 0, length);
                }

                LOGGER.info("Successfully copied file from " + sourcePath + " to " + destinationPath);
                return true;
            }
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Error copying file from " + sourcePath + " to " + destinationPath, e);
            return false;
        }
    }

    /**
     * Get the full absolute path for a file
     * @param filePath The relative or base filename
     * @return Full path including data directory if needed
     */
    private static String getFullPath(String filePath) {
        // If it's already absolute, return as is
        if (new File(filePath).isAbsolute()) {
            return filePath;
        }

        // If it already contains the data directory path, return as is
        if (filePath.startsWith(DATA_DIRECTORY)) {
            return filePath;
        }

        // Otherwise, combine with the data directory
        return DATA_DIRECTORY + File.separator + filePath;
    }
}