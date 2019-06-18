// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HairShaders/HairShader2_AS_RRF_Transparent"
{
	Properties
	{
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		_EdgeRimLight("EdgeRimLight", Range( 0 , 4)) = 0
		_BaseColorGloss("BaseColor-Gloss", Color) = (0.8455882,0.8076825,0.6839316,0.522)
		_BaseTone_Alpha("BaseTone_Alpha", 2D) = "white" {}
		_BaseTipColorPower("BaseTipColor-Power", Color) = (1,0,0,0)
		_AlphaLevel("AlphaLevel", Range( 0 , 2)) = 2
		_VariaitonFromBase("VariaitonFromBase", Range( 0 , 1)) = 0.8
		_NormalMap("NormalMap", 2D) = "bump" {}
		_BumpPower("BumpPower", Range( 0 , 1)) = 0.5
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_MainHighlight_Color("MainHighlight_Color", Color) = (0,0,0,0)
		_MainHighlightPosition("Main Highlight Position", Range( -1 , 3)) = 0
		_MainHighlightStrength("Main Highlight Strength", Range( 0 , 2)) = 0.25
		_MainHighlightExponent("Main Highlight Exponent", Range( 0 , 1000)) = 0.2
		_SecondaryHighlightColor("Secondary Highlight Color", Color) = (0.8862069,0.8862069,0.8862069,0)
		_SecondaryHighlightPosition("Secondary Highlight Position", Range( -1 , 3)) = 0
		_SecondaryHighlightStrength("Secondary Highlight Strength", Range( 0 , 2)) = 0.25
		_SecondaryHighlightExponent("Secondary Highlight Exponent", Range( 0 , 1000)) = 0.2
		_Spread("Spread", Range( -1 , 1)) = 0
		_Noise("Noise", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
		};

		struct SurfaceOutputStandardCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Translucency;
		};

		uniform float _BumpPower;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float4 _BaseTipColorPower;
		uniform float4 _BaseColorGloss;
		uniform sampler2D _BaseTone_Alpha;
		uniform float4 _BaseTone_Alpha_ST;
		uniform float4 _MainHighlight_Color;
		uniform float _MainHighlightPosition;
		uniform float _Noise;
		uniform float _Spread;
		uniform float _MainHighlightExponent;
		uniform float _MainHighlightStrength;
		uniform float _SecondaryHighlightPosition;
		uniform float _SecondaryHighlightExponent;
		uniform float _SecondaryHighlightStrength;
		uniform float4 _SecondaryHighlightColor;
		uniform float _VariaitonFromBase;
		uniform float _Metallic;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform float _EdgeRimLight;
		uniform float _AlphaLevel;

		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			#if !DIRECTIONAL
			float3 lightAtten = gi.light.color;
			#else
			float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, _TransShadow );
			#endif
			half3 lightDir = gi.light.dir + s.Normal * _TransNormalDistortion;
			half transVdotL = pow( saturate( dot( viewDir, -lightDir ) ), _TransScattering );
			half3 translucency = lightAtten * (transVdotL * _TransDirect + gi.indirect.diffuse * _TransAmbient) * s.Translucency;
			half4 c = half4( s.Albedo * translucency * _Translucency, 0 );

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + c;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode7 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _BumpPower );
			float3 lerpResult113 = lerp( float3(0.5,0.5,1) , tex2DNode7 , _BumpPower);
			float3 normalizeResult15 = normalize( lerpResult113 );
			o.Normal = normalizeResult15;
			float2 uv_BaseTone_Alpha = i.uv_texcoord * _BaseTone_Alpha_ST.xy + _BaseTone_Alpha_ST.zw;
			float4 tex2DNode1 = tex2D( _BaseTone_Alpha, uv_BaseTone_Alpha );
			float4 lerpResult293 = lerp( _BaseTipColorPower , _BaseColorGloss , pow( tex2DNode1.g , ( _BaseTipColorPower.a * 10.0 ) ));
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 T200 = cross( ase_worldTangent , ase_worldNormal );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float NoiseFX312 = ( ( tex2DNode7.g + ( _Noise - 0.5 ) ) * ( tex2DNode1.b * _Noise ) * _Spread );
			float4 appendResult305 = (float4(ase_worldlightDir.x , ( ( _MainHighlightPosition + NoiseFX312 ) + ase_worldlightDir.y ) , ase_worldlightDir.z , 0.0));
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float4 normalizeResult78 = normalize( ( appendResult305 + float4( ase_worldViewDir , 0.0 ) ) );
			float4 H93 = normalizeResult78;
			float dotResult95 = dot( float4( T200 , 0.0 ) , H93 );
			float dotTH94 = dotResult95;
			float sinTH97 = sqrt( ( 1.0 - ( dotTH94 * dotTH94 ) ) );
			float smoothstepResult103 = smoothstep( -1.0 , 0.0 , dotTH94);
			float dirAtten102 = smoothstepResult103;
			float dotResult279 = dot( ase_worldlightDir , ase_worldNormal );
			float clampResult290 = clamp( ( dotResult279 * dotResult279 * dotResult279 ) , 0.0 , 1.0 );
			float lightZone285 = clampResult290;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 temp_output_268_0 = ( _MainHighlight_Color * ( pow( sinTH97 , _MainHighlightExponent ) * _MainHighlightStrength * dirAtten102 * lightZone285 ) * ase_lightColor * ase_lightColor.a );
			float4 appendResult241 = (float4(ase_worldlightDir.x , ( ( _SecondaryHighlightPosition + NoiseFX312 ) + ase_worldlightDir.y ) , ase_worldlightDir.z , 0.0));
			float4 normalizeResult246 = normalize( ( appendResult241 + float4( ase_worldViewDir , 0.0 ) ) );
			float4 HL2247 = normalizeResult246;
			float dotResult249 = dot( HL2247 , float4( T200 , 0.0 ) );
			float DotTHL2252 = dotResult249;
			float sinTHL2256 = sqrt( ( 1.0 - ( DotTHL2252 * DotTHL2252 ) ) );
			float4 temp_output_265_0 = ( ( pow( sinTHL2256 , _SecondaryHighlightExponent ) * _SecondaryHighlightStrength * dirAtten102 * lightZone285 ) * _SecondaryHighlightColor * ase_lightColor * ase_lightColor.a );
			float4 temp_cast_4 = (1.0).xxxx;
			float4 lerpResult144 = lerp( temp_cast_4 , tex2DNode1 , _VariaitonFromBase);
			float4 clampResult275 = clamp( ( ( lerpResult293 + temp_output_268_0 + temp_output_265_0 ) * lerpResult144 ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			o.Albedo = clampResult275.rgb;
			o.Emission = ( temp_output_268_0 + temp_output_265_0 ).rgb;
			o.Metallic = ( tex2DNode1.r * _Metallic );
			o.Smoothness = _BaseColorGloss.a;
			float fresnelNdotV31 = dot( ase_worldNormal, ase_worldlightDir );
			float fresnelNode31 = ( -0.9 + 0.45 * pow( 1.0 - fresnelNdotV31, _EdgeRimLight ) );
			float fresnelNdotV205 = dot( ase_worldNormal, ase_worldlightDir );
			float fresnelNode205 = ( -0.1 + 0.9 * pow( 1.0 - fresnelNdotV205, 1.51 ) );
			float4 clampResult223 = clamp( ( clampResult275 * ( ( 1.0 - fresnelNode31 ) * fresnelNode205 ) ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			o.Translucency = clampResult223.rgb;
			o.Alpha = pow( ( tex2DNode1.a * tex2DNode1.a ) , _AlphaLevel );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustom alpha:fade keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandardCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16204
395;311;1377;732;911.3246;93.19055;1.806077;True;False
Node;AmplifyShaderEditor.RangedFloatNode;114;-68.51652,344.9161;Float;False;Property;_BumpPower;BumpPower;14;0;Create;True;0;0;False;0;0.5;0.141;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;310;92.79433,663.196;Float;False;Constant;_Float0;Float 0;22;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;308;6.263794,542.8472;Float;False;Property;_Noise;Noise;25;0;Create;True;0;0;False;0;0;0.522;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;261.4775,232.6432;Float;True;Property;_NormalMap;NormalMap;13;0;Create;True;0;0;False;0;None;1de9070d201b8d348bdd2252dadaa6ec;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-789.9749,-30.1701;Float;True;Property;_BaseTone_Alpha;BaseTone_Alpha;9;0;Create;True;0;0;False;0;None;613d8b2153fe9a3469fe566fbbccc21f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;309;418.8268,608.207;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;696.3017,477.7437;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;311;722.4737,330.1337;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;300;5.488602,441.9024;Float;False;Property;_Spread;Spread;24;0;Create;True;0;0;False;0;0;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;299;896.8495,466.2956;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;312;1240.075,552.5405;Float;False;NoiseFX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;313;-3261.71,-930.967;Float;True;312;NoiseFX;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;303;-3463.174,-756.631;Float;False;Property;_MainHighlightPosition;Main Highlight Position;17;0;Create;True;0;0;False;0;0;0.12;-1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;110;-2883.036,-900.6163;Float;False;1896.089;1190.117;BaseSpec;28;109;104;108;106;105;107;103;99;98;95;200;96;93;78;77;102;97;132;134;94;17;267;285;286;289;290;305;304;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;25;-3223.673,-1065.425;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;298;-3086.507,-660.5655;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;244;-3194.839,-1160.074;Float;False;Property;_SecondaryHighlightPosition;Secondary Highlight Position;21;0;Create;True;0;0;False;0;0;0.25;-1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;304;-2731.163,-643.2665;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;306;-2809.895,-1131.572;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;17;-2915.098,-880.8162;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;305;-2565.805,-694.2261;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;243;-2639.251,-1096.934;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-2437.987,-831.0706;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;241;-2389.892,-1077.019;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;78;-2240.189,-836.3262;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldNormalVector;198;-3529.824,-386.584;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;245;-2103.269,-1022.311;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexTangentNode;79;-3528.73,-619.2474;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CrossProductOpNode;197;-2976.426,-505.7399;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-2038.373,-806.1086;Float;False;H;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;246;-1910.786,-1029.374;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;247;-1442.094,-1029.97;Float;False;HL2;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-2690.921,-512.3536;Float;False;T;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-2742.448,-372.0709;Float;False;93;H;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;248;-2802.781,340.0659;Float;False;247;HL2;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DotProductOpNode;95;-2442.637,-476.7843;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;251;-2786.531,442.4142;Float;False;200;T;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-2265.698,-476.4357;Float;False;dotTH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;249;-2467.031,366.933;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-2757.113,-262.2531;Float;False;94;dotTH;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;252;-2222.172,372.2314;Float;False;DotTHL2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;280;-3686.534,-0.7129478;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;284;-3501.692,261.559;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;253;-1933.037,375.6393;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-2465.691,-261.2305;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;279;-3051.105,67.99283;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;134;-2261.824,-293.3675;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;254;-1731.987,391.3462;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;255;-1529.368,389.7755;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;132;-2059.687,-337.6208;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-2865.856,83.7582;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;256;-1329.89,389.7752;Float;False;sinTHL2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;290;-2646.396,126.1083;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;103;-2436.418,-114.2841;Float;False;3;0;FLOAT;-1;False;1;FLOAT;-1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;97;-1856.158,-343.6411;Float;False;sinTH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;262;-1864.757,693.3102;Float;False;Property;_SecondaryHighlightExponent;Secondary Highlight Exponent;23;0;Create;True;0;0;False;0;0.2;517;0;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;292;-749.9877,-878.1818;Float;False;Property;_BaseTipColorPower;BaseTipColor-Power;10;0;Create;True;0;0;False;0;1,0,0,0;0.125,0.1144016,0.1075368,0.397;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;102;-2179.553,-123.2158;Float;False;dirAtten;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;285;-2468.125,73.97447;Float;False;lightZone;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-1799.459,17.51375;Float;False;Property;_MainHighlightExponent;Main Highlight Exponent;19;0;Create;True;0;0;False;0;0.2;557;0;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;-1832.492,927.9147;Float;False;256;sinTHL2;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;297;-682.1694,-646.6733;Float;False;Constant;_Float2;Float 2;19;0;Create;True;0;0;False;0;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-1717.803,-60.69093;Float;False;97;sinTH;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;295;-489.3649,-648.4099;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;259;-1846.26,784.1027;Float;False;Property;_SecondaryHighlightStrength;Secondary Highlight Strength;22;0;Create;True;0;0;False;0;0.25;0.14;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;-1759.435,184.8097;Float;False;102;dirAtten;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;106;-1443.615,-142.4502;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-1794.21,98.11578;Float;False;Property;_MainHighlightStrength;Main Highlight Strength;18;0;Create;True;0;0;False;0;0.25;0.8;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;258;-1483.864,638.1011;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;286;-1646.583,262.7406;Float;False;285;lightZone;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;260;-1824.733,860.6061;Float;False;102;dirAtten;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;267;-1501.954,-433.6057;Float;False;Property;_MainHighlight_Color;MainHighlight_Color;16;0;Create;True;0;0;False;0;0,0,0,0;0.5441177,0.5441177,0.5441177,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;261;-1224.201,693.6574;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;314;-1196.473,506.5096;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-1276.295,-160.7519;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;294;-339.8072,-694.2356;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;264;-1219.661,851.2394;Float;False;Property;_SecondaryHighlightColor;Secondary Highlight Color;20;0;Create;True;0;0;False;0;0.8862069,0.8862069,0.8862069,0;0.6323529,0.479716,0.3161765,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;2;-872.1382,-576.4238;Float;False;Property;_BaseColorGloss;BaseColor-Gloss;8;0;Create;True;0;0;False;0;0.8455882,0.8076825,0.6839316,0.522;0.2426471,0.1255071,0,0.222;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;209;-365.4094,858.3539;Float;False;Constant;_Bias1;Bias1;19;0;Create;True;0;0;False;0;-0.9;-0.939;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;210;-365.4094,938.3539;Float;False;Constant;_Scale1;Scale1;21;0;Create;True;0;0;False;0;0.45;0.459;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;265;-801.9812,596.2473;Float;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-363.4138,1011.591;Float;False;Property;_EdgeRimLight;EdgeRimLight;7;0;Create;True;0;0;False;0;0;2.16;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;293;-164.4102,-662.8844;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-637.1672,-236.493;Float;False;Constant;_Float1;Float 1;12;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-647.7953,-153.0608;Float;False;Property;_VariaitonFromBase;VariaitonFromBase;12;0;Create;True;0;0;False;0;0.8;0.615;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;268;-932.6133,-322.5575;Float;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;273;179.0984,-470.9795;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;214;-371.3101,1334.191;Float;False;Constant;_Power2;Power2;25;0;Create;True;0;0;False;0;1.51;1.51;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;31;935.6188,721.78;Float;False;Standard;WorldNormal;LightDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;213;-364.4909,1151.055;Float;False;Constant;_Bias2;Bias2;23;0;Create;True;0;0;False;0;-0.1;0.148;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;212;-365.4909,1238.055;Float;False;Constant;_Scale2;Scale2;24;0;Create;True;0;0;False;0;0.9;0.905;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;144;-246.6127,-167.5198;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;204;1228.807,723.0435;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;205;948.2639,937.8943;Float;False;Standard;WorldNormal;LightDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;1414.221,-320.6941;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;219;1521.662,805.4762;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;112;277.38,40.46222;Float;False;Constant;_Vector0;Vector 0;10;0;Create;True;0;0;False;0;0.5,0.5,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;275;2047.285,-184.0741;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;2259.973,348.4926;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;29;591.8593,-22.00044;Float;False;Property;_Metallic;Metallic;15;0;Create;True;0;0;False;0;0;0.105;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;113;914.9343,77.11578;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-304.6455,93.49822;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-966.4499,247.1846;Float;False;Property;_AlphaLevel;AlphaLevel;11;0;Create;True;0;0;False;0;2;0.74;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;291;2597.496,266.8466;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;216;-653.4868,1162.769;Float;False;Constant;_Vector2;Vector 2;20;0;Create;True;0;0;False;0;-0.9,0.45,2.83;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;15;1105.024,37.289;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;215;-625.0445,1391.555;Float;False;Constant;_Vector1;Vector 1;20;0;Create;True;0;0;False;0;-0.1,0.9,1.51;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;4;-21.62289,184.0909;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;1206.498,-145.8922;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;223;2685.969,441.0745;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3236.149,373.6626;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;HairShaders/HairShader2_AS_RRF_Transparent;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;1;5;False;-1;2;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;0;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;5;114;0
WireConnection;309;0;308;0
WireConnection;309;1;310;0
WireConnection;307;0;1;3
WireConnection;307;1;308;0
WireConnection;311;0;7;2
WireConnection;311;1;309;0
WireConnection;299;0;311;0
WireConnection;299;1;307;0
WireConnection;299;2;300;0
WireConnection;312;0;299;0
WireConnection;298;0;303;0
WireConnection;298;1;313;0
WireConnection;304;0;298;0
WireConnection;304;1;25;2
WireConnection;306;0;244;0
WireConnection;306;1;313;0
WireConnection;305;0;25;1
WireConnection;305;1;304;0
WireConnection;305;2;25;3
WireConnection;243;0;306;0
WireConnection;243;1;25;2
WireConnection;77;0;305;0
WireConnection;77;1;17;0
WireConnection;241;0;25;1
WireConnection;241;1;243;0
WireConnection;241;2;25;3
WireConnection;78;0;77;0
WireConnection;245;0;241;0
WireConnection;245;1;17;0
WireConnection;197;0;79;0
WireConnection;197;1;198;0
WireConnection;93;0;78;0
WireConnection;246;0;245;0
WireConnection;247;0;246;0
WireConnection;200;0;197;0
WireConnection;95;0;200;0
WireConnection;95;1;96;0
WireConnection;94;0;95;0
WireConnection;249;0;248;0
WireConnection;249;1;251;0
WireConnection;252;0;249;0
WireConnection;253;0;252;0
WireConnection;253;1;252;0
WireConnection;99;0;98;0
WireConnection;99;1;98;0
WireConnection;279;0;280;0
WireConnection;279;1;284;0
WireConnection;134;0;99;0
WireConnection;254;0;253;0
WireConnection;255;0;254;0
WireConnection;132;0;134;0
WireConnection;289;0;279;0
WireConnection;289;1;279;0
WireConnection;289;2;279;0
WireConnection;256;0;255;0
WireConnection;290;0;289;0
WireConnection;103;0;98;0
WireConnection;97;0;132;0
WireConnection;102;0;103;0
WireConnection;285;0;290;0
WireConnection;295;0;292;4
WireConnection;295;1;297;0
WireConnection;106;0;105;0
WireConnection;106;1;107;0
WireConnection;258;0;257;0
WireConnection;258;1;262;0
WireConnection;261;0;258;0
WireConnection;261;1;259;0
WireConnection;261;2;260;0
WireConnection;261;3;286;0
WireConnection;109;0;106;0
WireConnection;109;1;108;0
WireConnection;109;2;104;0
WireConnection;109;3;286;0
WireConnection;294;0;1;2
WireConnection;294;1;295;0
WireConnection;265;0;261;0
WireConnection;265;1;264;0
WireConnection;265;2;314;0
WireConnection;265;3;314;2
WireConnection;293;0;292;0
WireConnection;293;1;2;0
WireConnection;293;2;294;0
WireConnection;268;0;267;0
WireConnection;268;1;109;0
WireConnection;268;2;314;0
WireConnection;268;3;314;2
WireConnection;273;0;293;0
WireConnection;273;1;268;0
WireConnection;273;2;265;0
WireConnection;31;1;209;0
WireConnection;31;2;210;0
WireConnection;31;3;211;0
WireConnection;144;0;143;0
WireConnection;144;1;1;0
WireConnection;144;2;145;0
WireConnection;204;0;31;0
WireConnection;205;1;213;0
WireConnection;205;2;212;0
WireConnection;205;3;214;0
WireConnection;3;0;273;0
WireConnection;3;1;144;0
WireConnection;219;0;204;0
WireConnection;219;1;205;0
WireConnection;275;0;3;0
WireConnection;39;0;275;0
WireConnection;39;1;219;0
WireConnection;113;0;112;0
WireConnection;113;1;7;0
WireConnection;113;2;114;0
WireConnection;28;0;1;4
WireConnection;28;1;1;4
WireConnection;291;0;268;0
WireConnection;291;1;265;0
WireConnection;15;0;113;0
WireConnection;4;0;28;0
WireConnection;4;1;5;0
WireConnection;30;0;1;1
WireConnection;30;1;29;0
WireConnection;223;0;39;0
WireConnection;0;0;275;0
WireConnection;0;1;15;0
WireConnection;0;2;291;0
WireConnection;0;3;30;0
WireConnection;0;4;2;4
WireConnection;0;7;223;0
WireConnection;0;9;4;0
ASEEND*/
//CHKSM=C276092D406ED9C0F0EB673A112AE16A2805278B