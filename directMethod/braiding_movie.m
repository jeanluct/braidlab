function braiding_movie(x_traj, y_traj, T1, Dyn, gen, tc, Movie)
       
close all

scrsz = get(0,'ScreenSize');
fig1 = figure('Position',[0 0 scrsz(3)/2 scrsz(4)]);

subplot(3,1,1);
axis([0 8 -3 3])
cla
Xsp = sortrows([x_traj(1,:)' y_traj(1,:)']);
loopplot(Dyn,[(1:size(x_traj,2))' Xsp(:,2)])      

L(:,1) = loopinter(Dyn);

if Movie =='y'
    aviobj = avifile('test20.avi','fps',10);
end

j = 1;
    
for i = 1:length(gen)
    
    Dyn_new = loopsigma(gen(i),Dyn);              
    L(:,end+1) = loopinter(Dyn_new);
    
    % For each interval of the 
    
    while i == max(find(tc<j)) && j <= max(T1)
        idx =  max(find(T1<tc(i)))+1;
        if i ~=1
            xinterpp = interp1(T1,x_traj,(tc(i)+tc(i-1))/2);
            yinterpp = interp1(T1,y_traj,(tc(i)+tc(i-1))/2);
            subplot(3,1,1);
            title(['t = ' num2str(j)],'FontSize',20)
            xlabel('Puncture Index','FontSize',15);
            ylabel('Y trajectory value','FontSize',15);
            set(gca,'FontSize',15)
            Xsp = sortrows([xinterpp' yinterpp']);
            axis([0 size(x_traj,2)+1 -3 3])
            cla
            loopplot(Dyn,[(1:size(x_traj,2))' Xsp(:,2)])        
        end

        subplot(3,1,2)
        cla
        axis([-2.5 2.5 -2.5 2.5])
        title('Phase Plane','FontSize',20)
        xlabel('X','FontSize',15)
        ylabel('Y','FontSize',15)
        set(gca,'FontSize',15)
        if idx>2000
            plot(x_traj(idx-2000:idx,:),y_traj(idx-2000:idx,:))
        else                
            plot(x_traj(1:idx,:),y_traj(1:idx,:))
        end
        hold on        
        plot(x_traj(idx,:),y_traj(idx,:),'kx','MarkerSize',10,'LineWidth',2)

        subplot(3,1,3)
        cla
        plot([0 tc(1:i)'],log(L))
        title('Interceptions','FontSize',20)
        xlabel('Time','FontSize',15)
        ylabel('ln(L(t))','FontSize',15)
        set(gca,'FontSize',15)
        
        if Movie =='y'
            F = getframe(fig1);
            aviobj = addframe(aviobj,F);
        end
        pause(1/24)
        
        j = j+1;
        
    end

    Dyn = Dyn_new;

end

if Movie =='y'
    aviobj = close(aviobj);
end