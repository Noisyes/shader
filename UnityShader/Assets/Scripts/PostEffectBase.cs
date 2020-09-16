using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectBase : MonoBehaviour
{
    // Start is called before the first frame update

    // Update is called once per frame
    protected void CheckResource()
    {
        bool isSupported = CheckSupport();
        if(!isSupported)
        {
            NotSupported();
        }
    }

    protected bool CheckSupport()
    {
        if(SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false)
        {
            Debug.LogWarning("not supported");
            return false;
        }
        return true;
    }

    protected void NotSupported()
    {
        enabled = false;
    }

    protected void Start()
    {
        CheckResource();
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader , Material material)
    {
        if (shader == null)
            return null;
        if(shader.isSupported && material && material.shader == shader)
        {
            return material;
        }
        if(!shader.isSupported)
        {
            return null;
        }
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            if (material)
                return material;
            else
                return null;
        }
    }

}
