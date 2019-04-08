#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#include <stdio.h>

#define u_char unsigned char
 
int x, height_1, height_2;
void combine(u_char *data1, u_char *data2) {
    int row_size = x * 4 * sizeof(u_char);
    int img1_size = height_1 * row_size;
    int img2_size = height_2 * row_size;
    u_char *output_data = (u_char *) malloc(img1_size + img2_size);
    memcpy(output_data, data1, img1_size);
    memcpy(output_data + img1_size, data2, img2_size);
    
    int result = stbi_write_jpg("output.jpg", x, height_1 + height_2, 4, output_data, 90);
    
    if (result) {
        puts("output.jpg was successfully written");
    } else {
        puts("Error writing output.jpg");
    }
    
    free(output_data);
}
 
int main(int argc, char** argv) {
    if(argc < 3) { 
        puts("Not enough actual parameters");
        return 1;
    }
    printf("Combining %s & %s into output.jpg\n", argv[1], argv[2]);
    
    int x2, n;
    u_char *data1 = stbi_load(argv[1], &x, &height_1, &n, 4);
    if (data1 == NULL) {
        printf("%s could not be loaded\n", argv[1]);
        return 1;
    }
    
    u_char *data2 = stbi_load(argv[2], &x2, &height_2, &n, 4);
    if (data2 == NULL) {
        printf("%s could not be loaded\n", argv[2]);
        return 1;
    }
    
    if (x != x2) {
        puts("Files have different width, cannot combing");
        return 1;
    }
    
    combine(data1, data2);
    stbi_image_free(data1);
    stbi_image_free(data2);
    return 0;
}