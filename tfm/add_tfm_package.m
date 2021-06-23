function add_tfm_package(MD)
iTfmPackage = MD.getPackageIndex('TFMPackage');
if(isempty(iTfmPackage))
    disp('TFM Package Not Found');
    MD.addPackage(TFMPackage(MD));
    iTfmPackage = MD.getPackageIndex('TFMPackage');
else
    disp('TFM Package Found');
end