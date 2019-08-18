#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define u_char unsigned char

int width, height;
void combine(u_char** images, int rows, int cols) {
    int pixel_size = 4 * sizeof(u_char);
    int outputWidth = width * cols;
    int outputHeight = height * rows;
    int numImages = rows * cols;
    
    u_char* output_data = (u_char*) malloc(outputWidth * outputHeight * pixel_size);
    
    int currentMajorRow = 0;
    int currentMajorColumn = 0;
    for (int i = 0; i < numImages; ++i) {
        for (int y  = 0; y < height; ++y) {
            int majorXOffset = currentMajorColumn * width;
            int majorYOffset = (currentMajorRow * height + y) * outputWidth;
            int majorOffset = (majorXOffset + majorYOffset) * pixel_size;
            int imageOffset = y * width * pixel_size;
            memcpy(output_data + majorOffset, images[i] + imageOffset, width * pixel_size);
        }
        currentMajorColumn++;
        if (currentMajorColumn == cols) {
            currentMajorColumn = 0;
            currentMajorRow++;
        }
    }
    
    int result = stbi_write_jpg("output.jpg", outputWidth, outputHeight, 4, output_data, 90);
    if (result) {
        puts("output.jpg was successfully written");
    } else {
        puts("Error writing output.jpg");
    }
    
    free(output_data);
}

void freeImages(u_char** images, int count) {
    for (int i = 0; i < count; i++) {
        stbi_image_free(images[i]);
    }
    free(images);
}

void computeNearSquareDimensions(int n, int* x, int* y) {
    int mid = ceil(sqrt((double) n));
    while (n % mid != 0) {
        --mid;
    }
    int other = n / mid;
    *x = mid > other ? mid : other;
    *y = n / *x;
}

u_char** loadImages(char* filename, int* count) {
    FILE* fp;
    fp = fopen(filename, "r");
    if (fp == NULL) {
         printf("%s could not be loaded\n", filename);
         return NULL;
    }
    
    *count = 0;
    char tempFilename[128];
    while (fgets(tempFilename, 128, fp)) {
        *count += 1;
    }
    if (*count == 0) {
        printf("No file names in %s\n", filename);
        return NULL;
    }
    fseek(fp, 0, SEEK_SET);
    
    
    printf("Loading %d images from %s\n", *count, filename);
    int temp_width, temp_height, n;
    u_char** result = (u_char**) malloc(*count * sizeof(u_char**));
    for (int i = 0; i < *count; ++i) {
        char currentFilename[128];
        fgets(currentFilename, 128, fp);

        int last = strlen(currentFilename) - 1;
        if (currentFilename[last] == '\n') {
            currentFilename[last] = '\0';
        }
        u_char *data = stbi_load(currentFilename, &temp_width, &temp_height, &n, 4);
        if (data == NULL) {
            printf("%s (file %d) could not be loaded\n", currentFilename, i);
            freeImages(result, i);
            fclose(fp);
            return NULL;
        }

        if (width < 0 || height < 0) {
            width = temp_width;
            height = temp_height;
        }

        if (width != temp_width || height != temp_height) {
            printf("%s has different dimensions, cannot combing\n", currentFilename);
            printf("Expected width %d, has width %d\n", width, temp_width);
            printf("Expected height %d, has height %d\n", height, temp_height);
            freeImages(result, i);
            fclose(fp);
            return NULL;
        }
        printf("Loaded %s\n", currentFilename);
        result[i] = data;
    }
    fclose(fp);
    return result;
}

int main(int argc, char** argv) {
    width = -1;
    height = -1;
    if(argc < 2) {
        puts("Not enough actual parameters");
        return 1;
    }
    char* filename = argv[1];
    int rows = 0, cols = 0, count;
    if (argc >= 3) {
        rows = atoi(argv[2]);
    }
    if (argc >= 4) {
        cols = atoi(argv[3]);
    }

    u_char** images = loadImages(filename, &count);
    if (images == NULL) {
        return 1;
    }
    
    if (rows == 0 || cols == 0) {
        puts("No row size passed, computing near square dimensions");
        computeNearSquareDimensions(count, &rows, &cols);
        printf("Dimensions: %d X %d\n", rows, cols);
    }
    
    printf("Combining the first %d images listed in %s of dimensions %dx%d into a %dx%d image saved as output.jpg\n", count, filename, width, height, width*cols, height*rows);
    combine(images, rows, cols);
    freeImages(images, count);
    return 0;
}