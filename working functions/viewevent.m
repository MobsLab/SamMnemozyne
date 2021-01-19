function viewevent(i,evt,lfp1,lfp2)
st=Start(evt); en=End(evt);
ss=intervalSet(st(i)-5000,en(i)+5000);
subplot(211)
plot(Data(Restrict(lfp1,ss)))
subplot(212)
plot(Data(Restrict(lfp2,ss)))
end