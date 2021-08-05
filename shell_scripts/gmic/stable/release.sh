releaseDir="/project/bioinformatics/Danuser_lab/shared/proudot/gmic-script-release/"
zip -r "$releaseDir/previous/$1-$(date +"%Y-%m-%d-%H:%M:%S").zip" $releaseDir/$1
rm $releaseDir/$1/*
cp *.sh *.desktop $releaseDir/$1

cp installQuickMIPDispTest.sh $releaseDir/
cp installQuickMIPDispStable.sh $releaseDir/

chmod a+x $releaseDir/installQuickMIPDispTest.sh
chmod a+x $releaseDir/installQuickMIPDispStable.sh
