HDRP extras and current progress:

Please note. This shader is a work in progress based on the current
ongoing development of the HD Render Pipeline with Unity 2018.2.x

This shader was created in Unity 2018.3.0f2 on Dec 14th, 2018.

----------------------------------------------------------------------------

The shader uses a new masking system called VRTC
Variation
Root
Tip 
Cutoff

Varitation (Red Channel) : is a greyscale streak image to represent each strand of hair where whait channels variation color 1 and black channels Variation Color 2 as seen in the material.

Root (Green Channel): is the color coming from the top of the texture, it is greyscale where white represents the root color as seen in the material, as it goes to black, it fased out to the Base Varation tones. It is driven from the color and amount (amount is the Alpha slider in the color selection window).

Tip (Blue Channel): is the greyscale image of the tip, coming from the bottom of the texture or hair strand texture. It is driven by the color and amount in the material. (amount is the Alpha slider in the color selection window).

Cutoff (Alpha Channel) : A greayscale/Black and white image of the hair stands. White will show the hair and black will be see through. An alpha cutoff amount slider is there to help drive the cutoff point.

Anisotropy - for the anisotropic effect
Smoothness - for how shiny/wet the hair looks
PushTangent - To shift the anistropic position

----------------------------------------------------------------------------

You will find 4 materials specific to HDRP
2 are driven from the HDRP lit-anistropic built in material shaders
2 are driven from my ShaderGraph Hair Shader

----------------------------------------------------------------------------

Requires:
Unity 2018.3.0f2 or above
Packages: Render Pipeline Core, HDRenderpipeline, ShaderGraph, PostProcess
Resources included: HDRI-MegaSun as part of HDRI Skies-Free https://assetstore.unity.com/packages/2d/textures-materials/sky/skybox-series-free-103633
Game resource hair mesh and textures. 
Resource material cannot be resold and are for demonstration purposes only.

----------------------------------------------------------------------------


Disclaimer/Copyright notice:
The Shader was created using ShaderGraph and so can be manipulated
however you need for your project but must not be resold. Reselling of this
shader will result in a potential claim or a conflict of interest and you will be
reported to Unity. It may only be altered and utilised for your own personal use or for commerical games which you help to create.

----------------------------------------------------------------------------

Contact:
me@robertramsay.co.uk
Unity Connect : Robert Ramsay or RRFreelance

