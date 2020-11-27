function mod_channelstoanalyze(varargin)
%==========================================================================
% Details: Modify ExpeInfo and ChannelToAnalyze folder with what is fed as
% varargin
%
% INPUTS:  **needs to be completed - some channels are missing**
%       - Bulb_deep
%       - Bulb_sup
%       - dHPC_deep
%       - dHPC_rip
%       - EKG
%       - PFCx_deep
%       - PFCx_sup
%       - PFCx_deltadeep
%       - PFCx_deltasup
%       - PFCx_spindle
%       - Ref
%
%
% NOTES:
%       - 
%
%   Written by Samuel Laventure - 2019
%      
%  see also...
%==========================================================================
load('ExpeInfo');

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'Bulb_deep'
            Bulb_deep = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.Bulb_deep=Bulb_deep;
            load('/ChannelsToAnalyse/Bulb_deep.mat');
            channel=Bulb_deep;
            save('Bulb_deep.mat','channel');
            if ~isnumeric(Bulb_deep) 
                error('Incorrect value for property ''Bulb_deep''.');
            end
        case 'Bulb_sup'
            Bulb_sup = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.Bulb_deep=Bulb_sup;
            load('/ChannelsToAnalyse/Bulb_sup.mat');
            channel=Bulb_sup;
            save('Bulb_sup.mat','channel');
            if ~isnumeric(Bulb_sup) 
                error('Incorrect value for property ''Bulb_sup''.');
            end
        case 'dHPC_deep'
            dHPC_deep = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.dHPC_deep=dHPC_deep;
            load('/ChannelsToAnalyse/dHPC_deep.mat');
            channel=dHPC_deep;
            save('dHPC_deep.mat','channel');            
            if ~isnumeric(dHPC_deep) 
                error('Incorrect value for property ''dHPC_deep''.');
            end
        case 'dHPC_rip'
            dHPC_rip = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.dHPC_deep=dHPC_rip;
            load('/ChannelsToAnalyse/dHPC_rip.mat');
            channel=dHPC_rip;
            save('dHPC_rip.mat','channel');  
            if ~isnumeric(dHPC_rip) 
                error('Incorrect value for property ''dHPC_rip''.');
            end    
        case 'EKG'
            EKG = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.EKG=EKG;
            load('/ChannelsToAnalyse/EKG.mat');
            channel=EKG;
            save('EKG.mat','channel');  
            if ~isnumeric(EKG) 
                error('Incorrect value for property ''EKG''.');
            end
        case 'PFCx_deep'
            PFCx_deep = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.PFCx_deep=PFCx_deep;
            load('/ChannelsToAnalyse/PFCx_deep.mat');
            channel=PFCx_deep;
            save('PFCx_deep.mat','channel');  
            if ~isnumeric(PFCx_deep) 
                error('Incorrect value for property ''PFCx_deep''.');
            end
        case 'PFCx_deltadeep'
            PFCx_deltadeep = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.PFCx_deltadeep=PFCx_deltadeep;
            load('/ChannelsToAnalyse/PFCx_deltadeep.mat');
            channel=PFCx_deltadeep;
            save('PFCx_deltadeep.mat','channel');
            if ~isnumeric(PFCx_deltadeep) 
                error('Incorrect value for property ''PFCx_deltadeep''.');
            end
         case 'PFCx_deltasup'
            PFCx_deltasup = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.PFCx_deltasup=PFCx_deltasup;
            load('/ChannelsToAnalyse/PFCx_deltasup.mat');
            channel=PFCx_deltasup;
            save('PFCx_deltasup.mat','channel');
            if ~isnumeric(PFCx_deltasup) 
                error('Incorrect value for property ''PFCx_deltasup''.');
            end
         case 'PFCx_spindle'
            PFCx_spindle = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.PFCx_spindle=PFCx_spindle;
            load('/ChannelsToAnalyse/PFCx_spindle.mat');
            channel=PFCx_spindle;
            save('PFCx_spindle.mat','channel');
            if ~isnumeric(PFCx_spindle) 
                error('Incorrect value for property ''PFCx_spindle''.');
            end   
         case 'Ref'
            Ref = varargin{i+1};
            ExpeInfo.ChannelToAnalyse.Ref=Ref;
            load('/ChannelsToAnalyse/Ref.mat');
            channel=Ref;
            save('Ref.mat','channel');
            if ~isnumeric(Ref) 
                error('Incorrect value for property ''Ref''.');
            end   
         otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
    save('ExpeInfo.mat','ExpeInfo.mat')
end




end