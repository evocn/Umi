// Umi
// Framebuffer
// Alex Hartford
// July 2023

fbo : GLuint;
render_texture : GLuint;

init_framebuffer :: () {
    glGenFramebuffers(1, *fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);

    glGenTextures(1, *render_texture);
    // "Bind" the newly created texture : all future texture functions will modify this texture
    glBindTexture(GL_TEXTURE_2D, render_texture);
    // Give an empty image to OpenGL
    glTexImage2D(GL_TEXTURE_2D, 0,GL_RGBA, PIXEL_WIDTH, PIXEL_HEIGHT, 0,GL_RGBA, GL_UNSIGNED_BYTE, cast(*void)0);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glBindTexture(GL_TEXTURE_2D, 0);

    glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, render_texture, 0);

    // Set the list of draw buffers.
    draw_buffers := GLenum.[GL_COLOR_ATTACHMENT0];
    glDrawBuffers(1, draw_buffers.data);

    result := glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if result != GL_FRAMEBUFFER_COMPLETE {
        log_error("Framebuffer problems. Result code: %\n", result);
        assert(false);
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}
