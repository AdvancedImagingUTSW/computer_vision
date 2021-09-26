versionDir="."
gmicScripPath="/home2/$USER/gmic-scripts-install/"


rm -r $gmicScripPath
mkdir $gmicScripPath
cp $versionDir/quickMIPMontage.sh $gmicScripPath/quickMIPMontage
cp $versionDir/quickMIPMovie.sh $gmicScripPath/quickMIPMovie
cp $versionDir/quickMIPDisp.sh $gmicScripPath/quickMIPDisp
cp $versionDir/quickMIPSwap.sh $gmicScripPath/quickMIPSwap.sh
cp $versionDir/testQuickMIP.sh $gmicScripPath/testQuickMIP.sh
cp $versionDir/gmic_scripts /home2/$USER/.gmic

chmod a+rx $gmicScripPath/quickMIPMovie 
chmod a+rx $gmicScripPath/quickMIPDisp 
chmod a+rx $gmicScripPath/quickMIPMontage 
chmod a+rx $gmicScripPath/quickMIPSwap.sh
chmod a+r home2/$USER/.gmic

rm ~/.local/share/applications/userapp-quickMIP*

cp $versionDir/userapp-quickMIPMontage-ZZZZZZ.desktop ~/.local/share/applications/
cp $versionDir/userapp-quickMIPMovie-ZZZZZZ.desktop ~/.local/share/applications/
cp $versionDir/userapp-quickMIPDisp-ZZZZZZ.desktop ~/.local/share/applications/

echo "export PATH=$PATH:/home2/$USER/gmic-scripts-install/" >> /home2/$USER/.bashrc
echo "export PATH=$PATH:/home2/$USER/gmic-scripts-install/" >> /home2/$USER/.gnomerc
source /home2/$USER/.bashrc
echo "Gmic-scripts have been successfully installed."
sleep 1s
