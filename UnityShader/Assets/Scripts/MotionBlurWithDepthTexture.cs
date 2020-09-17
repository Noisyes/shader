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

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            material.SetFloat("_BlurSize", blurSize);
            material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
            Matrix4x4 currentViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
            Matrix4x4 currentViewProjecitonInverseMatrix = currentViewProjectionMatrix.inverse;
            material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjecitonInverseMatrix);
            previousViewProjectionMatrix = currentViewProjectionMatrix;
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
