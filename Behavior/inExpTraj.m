ntest=4;

figure,
for i=1:ntest
	load(['behavResources' num2str(i) '.mat'],'Xtsd','Ytsd');
	x = Data(Xtsd);
	y = Data(Ytsd);
	clear Xtsd Ytsd
	
	%plot
	plot(x,y)
	hold on	
end
Name = ['Trajectories_' date];
title([Name])

print([pwd '/' Name],'-dpng','-r300')
