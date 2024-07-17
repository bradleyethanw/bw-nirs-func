function probe=getprobefrominfo(info)

% figure out what probe this is

modeParts=strsplit(info.Mode,'x');
m=str2num(modeParts{1});
n=str2num(modeParts{2});

switch(info.Mode)
    case('3x5')
       m=3;
       n=5;
    case('3x3')
        m=3;
        n=3;
    case('4x4')
        m=4;
        n=4;
    case('3x11')
        m=3;
        n=11;    
    otherwise
        % I don't want to just assume I can do this based on the mode
        error('This is a different probe design');
end

offset=15;

if(contains(info.probe,'Probe1'))
    [Y,X,Z]=meshgrid([0:-1:-m+1]*30,offset+[0:n-1]*30,0);
else % type II
    [Y,X,Z]=meshgrid([-m+1:1:0]*30,-offset+[0:-1:-n+1]*30,0);    
end

if(iseven(m) & iseven(n))
    SrcPos=[];
    DetPos=[];
    for i=1:m
        if(iseven(i))
            SrcPos=[SrcPos; [X((i-1)*m+1:2:i*m)' Y((i-1)*m+1:2:i*m)' Z((i-1)*m+1:2:i*m)']];
            DetPos=[DetPos; [X((i-1)*m+2:2:i*m)' Y((i-1)*m+2:2:i*m)' Z((i-1)*m+2:2:i*m)']];
        else
            SrcPos=[SrcPos; [X((i-1)*m+2:2:i*m)' Y((i-1)*m+2:2:i*m)' Z((i-1)*m+2:2:i*m)']];
            DetPos=[DetPos; [X((i-1)*m+1:2:i*m)' Y((i-1)*m+1:2:i*m)' Z((i-1)*m+1:2:i*m)']];
        end
          
    end
else
    SrcPos=[X(1:2:end)' Y(1:2:end)' Z(1:2:end)'];
    DetPos=[X(2:2:end)' Y(2:2:end)' Z(2:2:end)'];
end

[sI,dI]=meshgrid([1:size(SrcPos,1)],[1:size(DetPos,1)]);

WL=reshape(repmat(info.Wave_nm,length(sI(:)),1),[],1);

if(iscell(WL))
    WL=cell2mat(WL);
end


link=table([sI(:); sI(:)],[dI(:); dI(:)],WL,'VariableNames',{'source','detector','type'});
link=sortrows(link,{'detector','source','type'});

probe=nirs.core.Probe(SrcPos,DetPos,link);
probe.link=probe.link(probe.distances==30,:);

end
