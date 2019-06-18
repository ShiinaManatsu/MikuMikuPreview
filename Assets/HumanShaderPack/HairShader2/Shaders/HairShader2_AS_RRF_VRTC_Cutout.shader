// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HairShaders/HairShader2_AS_RRF_VRTC_Cutout"
{
	Properties
	{
		_Light_Bias("Light_Bias", Range( 0 , 0.1)) = 0
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Light_Scale("Light_Scale", Range( 0 , 10)) = 0
		_LightScatter("LightScatter", Range( 0 , 1)) = 0
		_BaseIllumination("BaseIllumination", Range( 0 , 1)) = 0.15
		_SSS("SSS", Range( 0 , 1)) = 0
		_NormalMap("NormalMap", 2D) = "bump" {}
		_VRTC("VRTC", 2D) = "white" {}
		[Toggle(_USEVRTC_BIASANDSCALE_ON)] _UseVRTC_BiasAndScale("UseVRTC_BiasAndScale?", Float) = 0
		_VRTC_Bias("VRTC_Bias", Range( 0 , 1)) = 0
		_VRTC_Scale("VRTC_Scale", Range( 0 , 4)) = 1
		_VariantColor1_GlossA("VariantColor1_Gloss(A)", Color) = (0.8897059,0.1308391,0.1308391,0.516)
		_Variant_Color2_GlossA("Variant_Color2_Gloss(A)", Color) = (0,0.1356491,0.7867647,0.516)
		_TipColorPowerA("TipColor-Power(A)", Color) = (0.9448277,1,0,0.484)
		_RootColorPowerA("RootColor-Power(A)", Color) = (0.1102941,0.1005623,0.1005623,0.453)
		_BumpPower("BumpPower", Range( 0 , 5)) = 0.5
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_MainHighlight_Color("MainHighlight_Color", Color) = (0,0,0,0)
		_MainHighlightPosition("Main Highlight Position", Range( -1 , 3)) = 0
		_MainHighlightStrength("Main Highlight Strength", Range( 0 , 2)) = 0.25
		_MainHighlightExponent("Main Highlight Exponent", Range( 0 , 1000)) = 0.2
		_SecondaryHighlightColor("Secondary Highlight Color", Color) = (0.8862069,0.8862069,0.8862069,0)
		_AlphaPower("AlphaPower", Range( 0 , 3)) = 1
		_SecondaryHighlightPosition("Secondary Highlight Position", Range( -1 , 3)) = 0
		_SecondaryHighlightStrength("Secondary Highlight Strength", Range( 0 , 2)) = 0.25
		_SecondaryHighlightExponent("Secondary Highlight Exponent", Range( 0 , 1000)) = 0.2
		_Spread("Spread", Range( 0 , 3)) = 0
		_NoisePower("NoisePower", Range( 0 , 2000)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TreeTransparentCutout"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		ZWrite On
		ZTest Less
		Offset  1 , 5
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#pragma shader_feature _USEVRTC_BIASANDSCALE_ON
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

		uniform float _BumpPower;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float4 _VariantColor1_GlossA;
		uniform float4 _Variant_Color2_GlossA;
		uniform sampler2D _VRTC;
		uniform float4 _VRTC_ST;
		uniform float _VRTC_Bias;
		uniform float _VRTC_Scale;
		uniform float4 _RootColorPowerA;
		uniform float4 _TipColorPowerA;
		uniform float4 _MainHighlight_Color;
		uniform float _MainHighlightPosition;
		uniform float _Spread;
		uniform float _NoisePower;
		uniform float _MainHighlightExponent;
		uniform float _MainHighlightStrength;
		uniform float _SecondaryHighlightPosition;
		uniform float _SecondaryHighlightExponent;
		uniform float _SecondaryHighlightStrength;
		uniform float4 _SecondaryHighlightColor;
		uniform float _BaseIllumination;
		uniform float _SSS;
		uniform float _Light_Bias;
		uniform float _Light_Scale;
		uniform float _LightScatter;
		uniform float _Metallic;
		uniform float _AlphaPower;
		uniform float _Cutoff = 0.5;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode7 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _BumpPower );
			o.Normal = tex2DNode7;
			float2 uv_VRTC = i.uv_texcoord * _VRTC_ST.xy + _VRTC_ST.zw;
			float4 tex2DNode335 = tex2D( _VRTC, uv_VRTC );
			#ifdef _USEVRTC_BIASANDSCALE_ON
				float4 staticSwitch369 = ( ( tex2DNode335 + _VRTC_Bias ) * _VRTC_Scale );
			#else
				float4 staticSwitch369 = tex2DNode335;
			#endif
			float4 break370 = staticSwitch369;
			float4 lerpResult328 = lerp( _VariantColor1_GlossA , _Variant_Color2_GlossA , break370.r);
			float4 lerpResult330 = lerp( lerpResult328 , _RootColorPowerA , ( _RootColorPowerA.a * break370.g ));
			float4 lerpResult332 = lerp( lerpResult330 , _TipColorPowerA , ( break370.b * _TipColorPowerA.a ));
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 T200 = cross( ase_worldTangent , ase_worldNormal );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float2 appendResult365 = (float2(_NoisePower , 0.1));
			float2 uv_TexCoord316 = i.uv_texcoord * appendResult365;
			float simplePerlin2D315 = snoise( uv_TexCoord316 );
			float NoiseFX312 = ( ( tex2DNode7.g + _Spread ) * ( tex2DNode335.r * simplePerlin2D315 ) * _Spread );
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
			float4 temp_output_273_0 = ( lerpResult332 + temp_output_268_0 + temp_output_265_0 );
			o.Albedo = temp_output_273_0.rgb;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorldDir343 = mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 0 ) ).xyz;
			float3 normalizeResult345 = normalize( objToWorldDir343 );
			float dotResult346 = dot( ase_worldlightDir , normalizeResult345 );
			float clampResult353 = clamp( ( ( ( dotResult346 + _Light_Bias ) * _Light_Scale ) * _LightScatter ) , 0.0 , 1.0 );
			float4 lerpResult339 = lerp( ( temp_output_268_0 + temp_output_265_0 ) , temp_output_273_0 , ( _BaseIllumination * _SSS * clampResult353 ));
			o.Emission = lerpResult339.rgb;
			o.Metallic = _Metallic;
			float lerpResult334 = lerp( _VariantColor1_GlossA.a , _Variant_Color2_GlossA.a , tex2DNode335.r);
			o.Smoothness = lerpResult334;
			float temp_output_336_0 = pow( tex2DNode335.a , _AlphaPower );
			o.Alpha = temp_output_336_0;
			clip( temp_output_336_0 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
261;671;1377;732;2638.88;1184.21;2.316744;True;False
Node;AmplifyShaderEditor.RangedFloatNode;364;-560.4775,758.3839;Float;False;Property;_NoisePower;NoisePower;27;0;Create;True;0;0;False;0;0;283;0;2000;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;365;-185.4786,778.6542;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-338.7289,173.7569;Float;False;Property;_BumpPower;BumpPower;15;0;Create;True;0;0;False;0;0.5;0.96;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;110;-3870.355,-768.6287;Float;False;2882.904;1761.292;BaseSpec;55;314;109;267;261;259;102;106;104;286;108;285;258;260;107;262;105;103;290;256;97;289;132;255;254;134;279;280;284;99;253;252;98;94;95;249;200;96;248;251;93;78;197;198;77;79;17;305;304;298;303;313;335;366;367;368;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;316;65.66108,703.813;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;225.063,78.97484;Float;True;Property;_NormalMap;NormalMap;6;0;Create;True;0;0;False;0;cf24829a9bef4734582a302bd6f6d130;19591b8e62d2fbc46bcc771f083d5bcc;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;300;-58.18081,486.8614;Float;False;Property;_Spread;Spread;26;0;Create;True;0;0;False;0;0;0.63;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;315;335.2147,663.4827;Float;False;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;335;-1624.538,-521.3983;Float;True;Property;_VRTC;VRTC;7;0;Create;True;0;0;False;0;None;782ef3ffdf428ce48934f5774562ea50;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;597.9113,523.8642;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;311;722.4737,330.1337;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;299;931.1138,355.8871;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;312;1244.766,335.1394;Float;False;NoiseFX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;313;-3422.639,-661.655;Float;True;312;NoiseFX;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;303;-3837.977,-578.5528;Float;False;Property;_MainHighlightPosition;Main Highlight Position;18;0;Create;True;0;0;False;0;0;0.03;-1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;25;-3378.034,-934.0533;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;244;-3194.839,-1160.074;Float;False;Property;_SecondaryHighlightPosition;Secondary Highlight Position;23;0;Create;True;0;0;False;0;0;0.06;-1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;298;-3054.06,-489.056;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;306;-2809.895,-1131.572;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;304;-2731.667,-511.2789;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;17;-2918.777,-752.0027;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;243;-2639.251,-1096.934;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;305;-2566.309,-562.2385;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-2438.491,-699.083;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;241;-2389.892,-1077.019;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;245;-2103.269,-1022.311;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;78;-2240.693,-704.3386;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldNormalVector;198;-3694.432,119.9227;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VertexTangentNode;79;-3749.171,-83.18208;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;246;-1910.786,-1029.374;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-2038.877,-674.1208;Float;False;H;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CrossProductOpNode;197;-2980.105,-376.9262;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;247;-1663.877,-1043.458;Float;False;HL2;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-2742.952,-240.0831;Float;False;93;H;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-2691.425,-380.3658;Float;False;T;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;251;-2790.21,571.2278;Float;False;200;T;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;248;-2806.46,468.8795;Float;False;247;HL2;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DotProductOpNode;95;-2443.141,-344.7966;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-2266.202,-344.448;Float;False;dotTH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;249;-2470.71,495.7466;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-2757.617,-130.2655;Float;False;94;dotTH;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;252;-2225.851,501.045;Float;False;DotTHL2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;284;-3699.141,715.5179;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;253;-1936.716,504.4529;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;280;-3693.497,528.7839;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-2466.195,-129.2428;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;341;-542.1967,1095.895;Float;False;1435.461;680.1272;ScatterLight;9;351;349;348;347;346;345;344;343;342;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;279;-3054.784,196.8065;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;134;-2262.328,-161.3798;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;254;-1735.666,520.1598;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;342;-492.1966,1380.533;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;366;-1778.109,-735.547;Float;False;Property;_VRTC_Bias;VRTC_Bias;9;0;Create;True;0;0;False;0;0;0.394;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;367;-1775.37,-626.2689;Float;False;Property;_VRTC_Scale;VRTC_Scale;10;0;Create;True;0;0;False;0;1;2.16;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;343;-225.4491,1401.88;Float;False;Object;World;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-2866.36,215.7459;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;132;-2060.191,-205.6331;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;368;-1378.451,-648.3219;Float;False;ConstantBiasScale;-1;;7;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SqrtOpNode;255;-1533.047,518.5891;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;345;49.59906,1414.142;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;103;-2436.922,17.70354;Float;False;3;0;FLOAT;-1;False;1;FLOAT;-1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;290;-2646.9,258.096;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;97;-1856.662,-211.6534;Float;False;sinTH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;256;-1333.569,518.5888;Float;False;sinTHL2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;344;-482.0544,1223.177;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;369;-1074.294,-647.9153;Float;False;Property;_UseVRTC_BiasAndScale;UseVRTC_BiasAndScale?;8;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;327;-1368.559,-831.4611;Float;False;Property;_Variant_Color2_GlossA;Variant_Color2_Gloss(A);12;0;Create;True;0;0;False;0;0,0.1356491,0.7867647,0.516;0.3000238,0.2134515,0.3455882,0.128;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;262;-1864.757,693.3102;Float;False;Property;_SecondaryHighlightExponent;Secondary Highlight Exponent;25;0;Create;True;0;0;False;0;0.2;16;0;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;346;321.943,1281.326;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;326;-1358.436,-995.2605;Float;False;Property;_VariantColor1_GlossA;VariantColor1_Gloss(A);11;0;Create;True;0;0;False;0;0.8897059,0.1308391,0.1308391,0.516;0.3794447,0.03162846,0.4779412,0.159;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;105;-1718.307,71.29671;Float;False;97;sinTH;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;329;-1247.375,-1268.273;Float;False;Property;_RootColorPowerA;RootColor-Power(A);14;0;Create;True;0;0;False;0;0.1102941,0.1005623,0.1005623,0.453;0.06176208,0.003243948,0.1470588,0.859;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;347;-247.6851,1548.879;Float;False;Property;_Light_Bias;Light_Bias;0;0;Create;True;0;0;False;0;0;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;348;-254.5041,1661.022;Float;False;Property;_Light_Scale;Light_Scale;2;0;Create;True;0;0;False;0;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;285;-2468.629,205.9621;Float;False;lightZone;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;102;-2180.057,8.771833;Float;False;dirAtten;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-1799.963,149.5014;Float;False;Property;_MainHighlightExponent;Main Highlight Exponent;20;0;Create;True;0;0;False;0;0.2;93;0;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;370;-689.6587,-690.0334;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;257;-1832.492,927.9147;Float;False;256;sinTHL2;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;106;-1444.119,-10.46254;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;292;-601.0289,-945.134;Float;False;Property;_TipColorPowerA;TipColor-Power(A);13;0;Create;True;0;0;False;0;0.9448277,1,0,0.484;0.1226943,0.01967995,0.6691177,0.903;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;258;-1483.864,638.1011;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;328;-873.0164,-873.1317;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;260;-1824.733,860.6061;Float;False;102;dirAtten;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-1794.714,230.1034;Float;False;Property;_MainHighlightStrength;Main Highlight Strength;19;0;Create;True;0;0;False;0;0.25;0.196;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;331;-824.2739,-1090.05;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;259;-1846.26,784.1027;Float;False;Property;_SecondaryHighlightStrength;Secondary Highlight Strength;24;0;Create;True;0;0;False;0;0.25;0.234;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;349;636.3331,1420.79;Float;False;ConstantBiasScale;-1;;6;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;-1759.939,316.7973;Float;False;102;dirAtten;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;351;664.2381,1582.202;Float;False;Property;_LightScatter;LightScatter;3;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;286;-1650.262,391.5542;Float;False;285;lightZone;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;261;-1224.201,693.6574;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;352;1276.955,1405.073;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;330;-555.3855,-1128.346;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;267;-1502.458,-301.618;Float;False;Property;_MainHighlight_Color;MainHighlight_Color;17;0;Create;True;0;0;False;0;0,0,0,0;0.6115484,0.3480753,0.6397059,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;314;-1193.189,506.5096;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;264;-1219.661,851.2394;Float;False;Property;_SecondaryHighlightColor;Secondary Highlight Color;21;0;Create;True;0;0;False;0;0.8862069,0.8862069,0.8862069,0;0.6010009,0.4298227,0.7794118,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;333;-251.2725,-872.6431;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-1276.799,-28.76422;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;332;56.15638,-964.2636;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;265;-801.9812,596.2473;Float;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;268;-893.8323,-162.9597;Float;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;357;1924.924,1055.266;Float;False;Property;_SSS;SSS;5;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;340;1930.022,924.8037;Float;False;Property;_BaseIllumination;BaseIllumination;4;0;Create;True;0;0;False;0;0.15;0.15;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;353;2158.686,1235.93;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;291;2338.998,347.5141;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;337;-938.0623,-329.3133;Float;False;Property;_AlphaPower;AlphaPower;22;0;Create;True;0;0;False;0;1;0.18;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;363;2260.958,892.0176;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;273;408.8425,-661.499;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;334;318.9912,-373.1996;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;336;3158.003,539.906;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;339;2384.452,637.9396;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;29;3056.948,391.6071;Float;False;Property;_Metallic;Metallic;16;0;Create;True;0;0;False;0;0;0.341;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4164.22,1340.478;Float;False;True;6;Float;ASEMaterialInspector;0;0;Standard;HairShaders/HairShader2_AS_RRF_VRTC_Cutout;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Off;1;False;-1;1;False;-1;True;1;False;-1;5;False;-1;False;5;Custom;0.5;True;True;0;True;TreeTransparentCutout;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;365;0;364;0
WireConnection;316;0;365;0
WireConnection;7;5;114;0
WireConnection;315;0;316;0
WireConnection;307;0;335;1
WireConnection;307;1;315;0
WireConnection;311;0;7;2
WireConnection;311;1;300;0
WireConnection;299;0;311;0
WireConnection;299;1;307;0
WireConnection;299;2;300;0
WireConnection;312;0;299;0
WireConnection;298;0;303;0
WireConnection;298;1;313;0
WireConnection;306;0;244;0
WireConnection;306;1;313;0
WireConnection;304;0;298;0
WireConnection;304;1;25;2
WireConnection;243;0;306;0
WireConnection;243;1;25;2
WireConnection;305;0;25;1
WireConnection;305;1;304;0
WireConnection;305;2;25;3
WireConnection;77;0;305;0
WireConnection;77;1;17;0
WireConnection;241;0;25;1
WireConnection;241;1;243;0
WireConnection;241;2;25;3
WireConnection;245;0;241;0
WireConnection;245;1;17;0
WireConnection;78;0;77;0
WireConnection;246;0;245;0
WireConnection;93;0;78;0
WireConnection;197;0;79;0
WireConnection;197;1;198;0
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
WireConnection;343;0;342;0
WireConnection;289;0;279;0
WireConnection;289;1;279;0
WireConnection;289;2;279;0
WireConnection;132;0;134;0
WireConnection;368;3;335;0
WireConnection;368;1;366;0
WireConnection;368;2;367;0
WireConnection;255;0;254;0
WireConnection;345;0;343;0
WireConnection;103;0;98;0
WireConnection;290;0;289;0
WireConnection;97;0;132;0
WireConnection;256;0;255;0
WireConnection;369;1;335;0
WireConnection;369;0;368;0
WireConnection;346;0;344;0
WireConnection;346;1;345;0
WireConnection;285;0;290;0
WireConnection;102;0;103;0
WireConnection;370;0;369;0
WireConnection;106;0;105;0
WireConnection;106;1;107;0
WireConnection;258;0;257;0
WireConnection;258;1;262;0
WireConnection;328;0;326;0
WireConnection;328;1;327;0
WireConnection;328;2;370;0
WireConnection;331;0;329;4
WireConnection;331;1;370;1
WireConnection;349;3;346;0
WireConnection;349;1;347;0
WireConnection;349;2;348;0
WireConnection;261;0;258;0
WireConnection;261;1;259;0
WireConnection;261;2;260;0
WireConnection;261;3;286;0
WireConnection;352;0;349;0
WireConnection;352;1;351;0
WireConnection;330;0;328;0
WireConnection;330;1;329;0
WireConnection;330;2;331;0
WireConnection;333;0;370;2
WireConnection;333;1;292;4
WireConnection;109;0;106;0
WireConnection;109;1;108;0
WireConnection;109;2;104;0
WireConnection;109;3;286;0
WireConnection;332;0;330;0
WireConnection;332;1;292;0
WireConnection;332;2;333;0
WireConnection;265;0;261;0
WireConnection;265;1;264;0
WireConnection;265;2;314;0
WireConnection;265;3;314;2
WireConnection;268;0;267;0
WireConnection;268;1;109;0
WireConnection;268;2;314;0
WireConnection;268;3;314;2
WireConnection;353;0;352;0
WireConnection;291;0;268;0
WireConnection;291;1;265;0
WireConnection;363;0;340;0
WireConnection;363;1;357;0
WireConnection;363;2;353;0
WireConnection;273;0;332;0
WireConnection;273;1;268;0
WireConnection;273;2;265;0
WireConnection;334;0;326;4
WireConnection;334;1;327;4
WireConnection;334;2;335;1
WireConnection;336;0;335;4
WireConnection;336;1;337;0
WireConnection;339;0;291;0
WireConnection;339;1;273;0
WireConnection;339;2;363;0
WireConnection;0;0;273;0
WireConnection;0;1;7;0
WireConnection;0;2;339;0
WireConnection;0;3;29;0
WireConnection;0;4;334;0
WireConnection;0;9;336;0
WireConnection;0;10;336;0
ASEEND*/
//CHKSM=E5FCAA86581851A011C365C6F47988C045438B6F