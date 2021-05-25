clear all

mnum = [828 905 911 912];

Dir = PathForExperimentsERC('UMazePAG');
Dir = RestrictPathForExperiment(Dir,'nMice',mnum);
 
for imouse=1:length(Dir.path)
    load([Dir.path{imouse}{1} '/ExpeInfo.mat'])

    ob.v1 = load([Dir.path{imouse}{1} '/old_sleepscoring/SleepScoring_OBGamma.mat'],'SWSEpoch','REMEpoch','Wake','TotalNoiseEpoch');
    ac.v1 = load([Dir.path{imouse}{1} '/old_sleepscoring/SleepScoring_Accelero.mat'],'SWSEpoch','REMEpoch','Wake','TotalNoiseEpoch');
    ob.v2 = load([Dir.path{imouse}{1} '/SleepScoring_OBGamma.mat'],'SWSEpoch','REMEpoch','Wake','TotalNoiseEpoch','Epoch');
    ac.v2 = load([Dir.path{imouse}{1} '/SleepScoring_Accelero.mat'],'SWSEpoch','REMEpoch','Wake','TotalNoiseEpoch','Epoch');

    % get epoch length 
    oblen{1,1} = (End(ob.v1.SWSEpoch)-Start(ob.v1.SWSEpoch))/1e4;
    aclen{1,1} = (End(ac.v1.SWSEpoch)-Start(ac.v1.SWSEpoch))/1e4;
    oblen{2,1} = (End(ob.v2.SWSEpoch)-Start(ob.v2.SWSEpoch))/1e4;
    aclen{2,1} = (End(ac.v2.SWSEpoch)-Start(ac.v2.SWSEpoch))/1e4;

    oblen{1,2} = (End(ob.v1.REMEpoch)-Start(ob.v1.REMEpoch))/1e4;
    aclen{1,2} = (End(ac.v1.REMEpoch)-Start(ac.v1.REMEpoch))/1e4;
    oblen{2,2} = (End(ob.v2.REMEpoch)-Start(ob.v2.REMEpoch))/1e4;
    aclen{2,2} = (End(ac.v2.REMEpoch)-Start(ac.v2.REMEpoch))/1e4;

    oblen{1,3} = (End(ob.v1.Wake)-Start(ob.v1.Wake))/1e4;
    aclen{1,3} = (End(ac.v1.Wake)-Start(ac.v1.Wake))/1e4;
    oblen{2,3} = (End(ob.v2.Wake)-Start(ob.v2.Wake))/1e4;
    aclen{2,3} = (End(ac.v2.Wake)-Start(ac.v2.Wake))/1e4;


    % get epoch length 
    nono_ob = ob.v2.Epoch-ob.v2.TotalNoiseEpoch; 
    nono_ac = ac.v2.Epoch-ac.v2.TotalNoiseEpoch; 
    oblen{1,1} = (End(and(ob.v1.SWSEpoch,nono_ob))-Start(and(ob.v1.SWSEpoch,nono_ob)))/1e4;
    aclen{1,1} = (End(and(ac.v1.SWSEpoch,nono_ac))-Start(and(ac.v1.SWSEpoch,nono_ac)))/1e4;

    oblen{1,2} = (End(and(ob.v1.REMEpoch,nono_ob))-Start(and(ob.v1.REMEpoch,nono_ob)))/1e4;
    aclen{1,2} = (End(and(ac.v1.REMEpoch,nono_ac))-Start(and(ac.v1.REMEpoch,nono_ac)))/1e4;

    oblen{1,3} = (End(and(ob.v1.Wake,nono_ob))-Start(and(ob.v1.Wake,nono_ob)))/1e4;
    aclen{1,3} = (End(and(ac.v1.Wake,nono_ac))-Start(and(ac.v1.Wake,nono_ac)))/1e4;

    % get stage duration
    for j=1:2
        for i=1:3
            obdur{j,i} = sum(oblen{j,i});
            acdur{j,i} = sum(aclen{j,i});
        end
    end
    % get noise duration
    obnoise{1} = sum((End(ob.v1.TotalNoiseEpoch)-Start(ob.v1.TotalNoiseEpoch))/1e4);
    acnoise{1} = sum((End(ac.v1.TotalNoiseEpoch)-Start(ac.v1.TotalNoiseEpoch))/1e4);
    obnoise{2} = sum((End(ob.v2.TotalNoiseEpoch)-Start(ob.v2.TotalNoiseEpoch))/1e4);
    acnoise{2} = sum((End(ac.v2.TotalNoiseEpoch)-Start(ac.v2.TotalNoiseEpoch))/1e4);

    stage={'NREM','REM','Wake'};

    supertit = num2str(ExpeInfo.nmouse);
    figH = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1500 1000],'Name', supertit, 'NumberTitle','off');
       for i=1:3    
            pos  = ((i-1)*10)+1;
            pos2 = pos+3;
            pos3 = pos+4;

            subplot(3,10,pos:pos+2)
                for j=1:2
                    histogram(oblen{j,i},20, ...
                        'FaceAlpha',0.5,'EdgeAlpha',0.5)
                    hold on
                end
                title([stage{i} ' - OB Gamma'])
                xlabel('seconds')
                if i==1
                    legend({'Original','New'})
                end

            subplot(3,10,pos+5:pos+7)
                for j=1:2
                    histogram(aclen{j,i},20, ...
                        'FaceAlpha',0.5,'EdgeAlpha',0.5)
                    hold on
                end
                title([stage{i} ' - Accelero'])
                xlabel('seconds')
                if i==1
                    legend({'Original','New'})
                end

             subplot(3,10,pos2)
                dif=obdur{2,i}-obdur{1,i};
                maxy=abs(dif)*1.15;
                miny=abs(dif)*-1.15;
                bar(dif), ylim([miny maxy])
                set(gca,'xtick',[])            
                if i==1,title({'TOTAL DUR.','New-Orig (in sec)'}),end

             subplot(3,10,pos2+5)
                dif=acdur{2,i}-acdur{1,i};
                maxy=abs(dif)*1.15;
                miny=abs(dif)*-1.15;
                bar(dif), ylim([miny maxy])
                set(gca,'xtick',[])
                if i==1,title({'TOTAL DUR.','New-Orig (in sec)'}),end
             if i==1
                 subplot(3,10,pos3)
                    dif=obnoise{2}-obnoise{1};
                    maxy=abs(dif)*1.15;
                    miny=abs(dif)*-1.15;
                    bar(dif), ylim([miny maxy])
                    set(gca,'xtick',[])            
                    if i==1,title({'NOISE','New-Orig (in sec)'}),end

                 subplot(3,10,pos3+5)
                    dif=acnoise{2}-acnoise{1};
                    maxy=abs(dif)*1.15;
                    miny=abs(dif)*-1.15;
                    bar(dif), ylim([miny maxy])
                    set(gca,'xtick',[])
                    if i==1,title({'NOISE','New-Orig (in sec)'}),end            
             end

        end

        annotation('textbox',[.05 .95 .75 .04],'String',supertit,'FitBoxToText','on','FontSize',22)

        dirPath = [dropbox 'DataSL/SleepScoring/']; 
        figName =  [supertit '_sscoring_comp'];
        saveF(figH,figName,dirPath,'sformat',{'dpng'},'res',300,'savfig',0)
end

        
        

