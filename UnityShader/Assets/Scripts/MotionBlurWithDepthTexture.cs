using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepthTexture : PostEffectBase
{
    public Shader MotionBlurWithDepthShader;
    private Material MotionBlurWithDepthMaterial;
    public Material material
    {
        get
        {
            MotionBlurWithDepthMaterial = CheckShaderAndCreateMaterial(MotionBlurWithDepthShader, MotionBlurWithDepthMaterial);
            return MotionBlurWithDepthMaterial;
        }
    }
    [Range(0.0f, 1.0f)]
    public float blurSize = 0.5f;
    private Camera myCamera;
    public Camera camera
    {
        get
        {
            if(myCamera == null)
            {
                myCamera = GetComponent<Camera>();

            }
            return myCamera;
        }
    }
    private Matrix4x4 previousViewProjectionMatrix;
    private void OnEnable()
    {
        camera.depthTextureMode |= DepthTextureMode.Depth;
    }
}
