import microvolution_py as mv
import numpy as np
import tifffile
import sys

lic = mv.Licensing.GetInstance()
print(lic.HaveValidLicense("deconvolution"))

f = tifffile.imread("/archive/MIL/friedman/yeast/Mic60GFP-HDEL646/200618/Cell1/1_CH00_000000.tif")
print(f.shape)

params = mv.DeconParameters()
params.nx = f.shape[2]
params.ny = f.shape[1]
params.nz = f.shape[0]
params.generatePsf = True
params.NA = 1.49
params.RI = 1.515
params.ns = 1.33
params.psfModel = mv.PSFModel_Vectorial
params.psfType = mv.PSFType_Confocal
params.wavelength = 525.0
params.dr = 160.0
params.dz = 200.0
params.iterations = 10
params.pinhole = 350
params.background = 2800
params.scaling = mv.Scaling_U16

try:
  launcher = mv.DeconvolutionLauncher()
  #launcher.SetDevice(0)
  f = f.astype(np.float32)
  
  launcher.SetParameters(params)
  for z in range(params.nz):
    launcher.SetImageSlice(z, f[z,:])
  launcher.Run()
  for z in range(params.nz):
    launcher.RetrieveImageSlice(z, f[z,:])
  tifffile.imsave("test.tif", f)
except:
  err = sys.exc_info()
  print("Unexpected error:", err[0])
  print(err[1])
  print(err[2])
