@echo off
REM In order for this batch script to work, you need to run the SFM Source SDK and have the %VGAME% variable pointing to SFM.
REM If this will conflict with any mods or other source engine game you're developing for, change %VGAME% to a folder where the SFM executable is located.
echo Starting Source Filmmaker with settings suitable for rendering.
echo=
echo It is advised not to save your projects with these settings on, as it will possibly lead to project corruption! 
echo=
echo Visit https://thunderysteak.github.io/sfm-best-quality for more info.
echo=
timeout 10
start "" "%VGAME%\sfm.exe" -nosteam -nop4 -num_edicts 8192 -sfm_resolution 2160 -sfm_shadowmapres 8192 -monitortexturesize 1024 -r_novis 1 -reflectiontexturesize 1024 +mat_envmapsize 256 +mat_forceaniso 16 +r_waterforceexpensive 1 +r_waterforcereflectentities 1 +mat_wateroverlaysize 1024 +r_hunkalloclightmaps 0 +flex_smooth 0
exit