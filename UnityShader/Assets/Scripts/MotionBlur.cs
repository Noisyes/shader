﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectBase
{
    public Shader MotionBlurShader;
    private Material MotionBlurMaterial;
    public Material material
    {
        get
        {
            MotionBlurMaterial = CheckShaderAndCreateMaterial(MotionBlurShader, MotionBlurMaterial);
            return MotionBlurMaterial;
        }
    }
    [Range(0.0f, 0.9f)]
    public float blurAmount = 0.5f;
    private RenderTexture accumulationTexture;

    private void OnDestroy()
    {
        DestroyImmediate(accumulationTexture);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            if(accumulationTexture == null || accumulationTexture.width != source.width
                || accumulationTexture.height != source.height)
            {
                DestroyImmediate(accumulationTexture);
                accumulationTexture = new RenderTexture(source.width, source.height, 0);
                accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(source, accumulationTexture);
            }
            accumulationTexture.MarkRestoreExpected();
            material.SetFloat("_BlurAmount", 1.0f - blurAmount);
            Graphics.Blit(source, accumulationTexture, material);
            Graphics.Blit(accumulationTexture, destination);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
