using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class MyCustomPostProcessing : ScriptableRendererFeature
{
    public Material postProcessMaterial;
    private CustomPostProcessPass customPass;

    public override void Create()
    {
        customPass = new CustomPostProcessPass(postProcessMaterial)
        {
            renderPassEvent = RenderPassEvent.AfterRenderingTransparents
        };
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (postProcessMaterial != null)
        {
            // Setup the custom pass with the correct render target (cameraColorTarget)
            customPass.Setup(renderer);
            renderer.EnqueuePass(customPass);
        }
    }
}

public class CustomPostProcessPass : ScriptableRenderPass
{
    private Material postProcessMaterial;
    private RenderTargetIdentifier source;
    private RenderTargetHandle temporaryColorTexture;

    public CustomPostProcessPass(Material material)
    {
        this.postProcessMaterial = material;
        temporaryColorTexture.Init("_TemporaryColorTexture");
    }

    public void Setup(ScriptableRenderer renderer)
    {
        this.source = renderer.cameraColorTargetHandle.nameID;
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (postProcessMaterial == null)
        {
            return;
        }

        CommandBuffer cmd = CommandBufferPool.Get("CustomPostProcess");

        RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
        opaqueDesc.depthBufferBits = 0;

        // Get a temporary render texture
        cmd.GetTemporaryRT(temporaryColorTexture.id, opaqueDesc);

        // Blit from source to temporary render texture using the post-process material
        Blit(cmd, source, temporaryColorTexture.Identifier(), postProcessMaterial);

        // Blit back to source from temporary render texture
        Blit(cmd, temporaryColorTexture.Identifier(), source);

        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    public override void FrameCleanup(CommandBuffer cmd)
    {
        cmd.ReleaseTemporaryRT(temporaryColorTexture.id);
    }
}