%Preprocessing_PAGest_SL
% 08.03.2018 Created from PreprocessingHardrive 08.03.2018 DB
% 16.10.2018


function Preprocessing_PAGTest_SL(dirin, indir, indir_beh, postorpre)

try
   dirin;
catch
   dirin='/media/DataMOBsRAIDN/Sam/M799/20181130/';
end

try
   postorpre;
catch
   postorpre = 0;
end

% Vector of used intensities
%  
%--------------TEMPLATES--------------- 
%
% V = {'0.0','0.5','1.0','1.5','2.0','2.5','3.0','3.5','4.0','4.5','5.0','5.5','6.0','6.5','7.0'};
% v = [0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7];

V = {'0.0','1.0','3.0','4.0','5.0','5.5','6.5','7.0'};  
v = [0 1 3 4 5 5.5 6.5 7];



% List folders inside Calibration
L=dir(dirin);
j=1; % counter for intensities in the loop

for i=1:length(L)
    if L(i).isdir
        %if strcmp (L(i).name,['Calib' V{j} 'V'])
            
            %Dir = [dirin '/Calib' V{j} 'V/'];
            Dir = dirin;
            cd(Dir);
    
            %% Get info about the dataset
            % GenMakeDataInputs
            spk=false;
            doaccelero = true;
            dodigitalin = true;
            doanalogin = false;
            Questions={'SpikeData (yes/no)', 'INTAN accelero', 'INTAN Digital input', 'INTAN Analog input'};           
            answerdigin{1,1} = '7';
            answerdigin{2,1} = '4           ';
            
            save makedataBulbeInputs Questions spk doaccelero dodigitalin doanalogin answerdigin
            clear Questions spk doaccelero dodigitalin doanalogin answerdigin
            
            % GenInfoLFPFromSpread
            structure_list = {'nan', 'ref', 'bulb', 'hpc', 'dhpc', 'pfcx', 'pacx', 'picx', 'mocx', 'aucx', 's1cx', 'th', 'nrt', 'auth', 'mgn', 'il', 'tt', ...
                            'amyg', 'vlpo','ekg','emg', 'digin', 'accelero'};
            hemisphere_list = {'r','l','nan'};
            depth_list = [-1 0 1 2 3];
            try
                load LFPData/InfoLFP InfoLFP
                m = input('Info LFP already exists - Do you want to rewrite it ? Y/N [Y]:','s');
    
            catch
                disp('creating InfoLFP...');
                m = 'y';
            end
            
            try
                [num,str] = xlsread('/media/mobs/DataMOBS85/PAG tests/M784/ChanLFP.xlsx');
            catch
                error('xls file cannot be read');
            end
            
            InfoLFP.channel = num(:,1);
            InfoLFP.depth = num(:,3);
            for k=1:length(InfoLFP.channel)
                InfoLFP.structure{k} = str{k,1};
                InfoLFP.hemisphere{k} = str{k,3};
            end
            clear num str

            if ~all(ismember(InfoLFP.depth, depth_list) | isnan(InfoLFP.depth))
                disp(InfoLFP.depth)
                error('one depth value is not correct')
            end
            if ~all(ismember(lower(InfoLFP.structure), structure_list))
                disp(InfoLFP.structure)
                error('one structure input is not correct')
            end
            if ~all(ismember(lower(InfoLFP.hemisphere), hemisphere_list))
                disp(InfoLFP.hemisphere)
                error('one structure input is not correct')
            end

            mkdir('LFPData')
            save('LFPData/InfoLFP.mat','InfoLFP');
            
            %GenChannelsToAnalyse
            res=pwd;
            if ~exist([res '/ChannelsToAnalyse'],'dir') % 01.04.2018 Dima
                mkdir('ChannelsToAnalyse');
            end
            
            channel = 0; % Here, best EKG channel
            save(['ChannelsToAnalyse/','EKG.mat'],'channel');
    
    
            %% Get folders
            try
                indir;
            catch
                indir ={'ERC-Mouse-799-20181130-Sleep_181130_145458/'
                };
            end

            try
                indir_beh;
            catch
                indir_beh={'SLEEP-Mouse-799-30112018-Sleep_00/'
                };
            end
    
            %% NDM shit
            if postorpre == 0
                NDM_SL(Dir, indir{j}, indir_beh{j})
                %NDM_PAGTest_SL(Dir, indir{j}, indir_beh{j}, v, V, j)
            else
                NDM_DB_pre_post(Dir, indir, indir_beh, postorpre)
            end
            j=j+1;
        %end
    end
end
end