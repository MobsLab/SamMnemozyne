%Preprocessing_harddrive_SL
% 10.10.2018 

function Preprocessing_harddrive_SL(dirin, indir, indir_beh, postorpre)


try
   dirin;
catch
   dirin={'/media/mobs/DataMOBS85/PAG tests/M792/18092018/CalibContextA/'};
end

try
   postorpre;
catch
   %postorpre = 'TestPre';
   postorpre = 0;
end
 
for i=1:length(dirin)
    Dir=dirin;
    %Dir=dirin{1};
    cd(Dir{1});
    
    %% Get info about the dataset
    GetBasicInfoRecord
    
    
%%    
try
   indir;
catch
   indir = {'raw/PAG-Mouse-789-19092018-TestPost1_180919_142401/';
        'raw/PAG-Mouse-789-19092018-TestPost2_180919_142753/'
        }
end

try
   indir_beh;
catch
   indir_beh = {'raw/ERC-Mouse-789-19092018-TestPost_00/';
       'raw/ERC-Mouse-789-19092018-TestPost_01/'
        };
end
    
    %% NDM shit
    if postorpre == 0
        NDM_SL(Dir, indir, indir_beh)
    else
        NDM_SL_pre_post(Dir, indir, indir_beh, postorpre)
    end
end
end
