Shader "Custom/LightSwitch"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        _SpecColor("Spec Color", Color) = (1,1,1,1)
        _SpecPower("SPec power", Float) = 1
        _LightMode("light mode", Float) = 0
        
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD1;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD2;
                float3 viewDirWS : TEXCOORD3;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
                float4 _SpecColor;
                float _SpecPower;
                float _LightMode;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalWS);
                OUT.viewDirWS = normalize(GetCameraPositionWS() - OUT.positionWS);
                
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;
                float3 lightDir = normalize(GetMainLight().direction);
                float colorMul = 1;
                float colorAdd = 0;
                
                switch (_LightMode)
                {
                case 0:
                    {
                        //diffuse
                        float NdotL = saturate(dot(normalize(IN.normalWS), lightDir));
                        colorMul = NdotL;
                        break;
                        
                    }
                case 1:
                    {
                        //ambient
                        float3 ambient = SampleSH(IN.normalWS);
                        colorAdd = ambient;
                        break;
                    }
                case 2:
                    {
                        //spec
                        float3 reflectDir = reflect(-lightDir, IN.normalWS);
                        half3 viewDir = normalize(IN.viewDirWS);
                        half specFactor = pow(saturate(dot(reflectDir, viewDir)), _SpecPower);
                        float3 specular = _SpecColor * specFactor;
                        colorAdd = specular;
                        break;
                    }
                }
                
                color = color * colorMul + colorAdd;
                
                return color;
            }
            ENDHLSL
        }
    }
}
