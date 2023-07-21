using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenQuad : MonoBehaviour
{
    public Material quadMaterial;

    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        if (!quadMaterial) {
            Graphics.Blit(src, dst);
            return;
        }

        RenderTexture.active = dst;

        quadMaterial.SetTexture("_MainTex", src);
        GL.PushMatrix();
        GL.LoadOrtho();
        quadMaterial.SetPass(0);
        GL.Begin(GL.QUADS);

        //BL
        GL.MultiTexCoord2(0, 0.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 0.0f);
        //BR
        GL.MultiTexCoord2(0, 1.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 0.0f);
        //TR
        GL.MultiTexCoord2(0, 1.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 0.0f);
        //TL
        GL.MultiTexCoord2(0, 0.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 0.0f);

        GL.End();
        GL.PopMatrix();
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
