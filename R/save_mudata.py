# from mudata import MuData
# from anndata import AnnData
# import numpy as np
# import pandas as pd
# 
# 
# def save_mudata(object, dname, x_name, y_name,**kwargs):
#   # Get blocks and metadata and other useful params
#   blocks = object.get(x_name)
#   metadata = pd.DataFrame({"response":object.get(y_name)})
#   
#   var_names = kwargs['var_names']
# 
#   
# 
#   # Combine to mudata
#   mu_dict = {}
#   for b, mat in blocks.items():
#     var = pd.DataFrame(var_names[b], columns=["feature"])
#     ann = AnnData(X = mat, 
#                   obs = metadata, 
#                   var = var)
#     ann.obs_names = kwargs['sample_names']
#     ann.var_names = var_names[b]
#     mu_dict[b] = ann  
#   
#   # store to mudata
#   mdata = MuData(mu_dict)
#   output_name = f"{dname}.h5mu"
#   mdata.write(output_name)
#   return mdata
