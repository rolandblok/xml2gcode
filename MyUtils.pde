







static boolean fEQ(float A, float B, float acc) {
  return abs(A-B) < acc;
}




// https://stackoverflow.com/questions/285955/java-get-the-newest-file-in-a-directory
public static File getLastModified(String directoryFilePath)
{
    File directory = new File(directoryFilePath);
    File[] files = directory.listFiles(File::isFile);
    long lastModifiedTime = Long.MIN_VALUE;
    File chosenFile = null;

    if (files != null)
    {
        for (File file : files)
        {
            if (file.lastModified() > lastModifiedTime)
            {
                chosenFile = file;
                lastModifiedTime = file.lastModified();
            }
        }
    }

    return chosenFile;
}

// https://stackoverflow.com/questions/924394/how-to-get-the-filename-without-the-extension-in-java
static String stripExtension (String str) {
        // Handle null case specially.

        if (str == null) return null;

        // Get position of last '.'.

        int pos = str.lastIndexOf(".");

        // If there wasn't any '.' just return the string as is.

        if (pos == -1) return str;

        // Otherwise return the string, up to the dot.

        return str.substring(0, pos);
}
  
  
