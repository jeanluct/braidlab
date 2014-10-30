function modified_duffing_tutorial

%% Load Modified duffing oscillator test data set
% 
% This will load the trajectories stored as xTrajModDuff

load modified_duffing.mat

%% Plot the trajectories
% 
% We plot a brief visulization of the trajectories

trajectory_animation(xTrajModDuff);

pause

%% Step 1: Produce the braid and act on the pair-loops

[loops, loopIndex, system_braid] = braidlab.lcs.Step1_PairLoopModification(xTrajModDuff);

% For reference the pair-loops considered are plotted for this tutorial

pair_loop_plot(system_braid);

pause

%% Step 2: Calculation of the Entangled Puncture Sets (EPSs)
% Using the modified pair-loops, we calculate the complement to the
% entangled puncture sets.

nes_combined = braidlab.lcs.Step2_CreateEPS(system_braid,loops,loopIndex);

% We now replot the initial pair loops to demonstrate which punctures
% become entangled by the advection.  The punctures entangled by a given
% loop are green.  Punctures not entangled by a loop are red.

entangled_puncture_plot(system_braid,nes_combined)

pause

%% Step 3: Identify the Invariant Puncture Sets (IPSs)
% The entangled puncture sets are then used to form the invariant puncture
% sets

punctureAssignment = braidlab.lcs.Step3_FindIPS(nes_combined,system_braid.n);

ips_plot(punctureAssignment)

pause

%% Step 4: Calculation of the slowly growing loops
% Finally we attempt to form a non-growing loop around the punctures in the
% invariant puncture set

for i = 1:max(punctureAssignment)
    nonGrowingLoop(i) = braidlab.lcs.Step4_DynCreation(system_braid,punctureAssignment,i,permute(xTrajModDuff(1,:,:),[3 2 1]));
end

nonGrowingLoop_plot(nonGrowingLoop,punctureAssignment)

end

function trajectory_animation(xTraj)

xMax = max(max(max(xTraj(:,1,:))));
xMin = min(min(min(xTraj(:,1,:))));
rX = xMax-xMin;
yMax = max(max(max(xTraj(:,2,:))));
yMin = min(min(min(xTraj(:,2,:))));
rY = yMax-yMin;
tailLength = 40;

for i = 1:8:size(xTraj,1);
    hold off
    if i<tailLength+1
        for j = 1:size(xTraj,3);
            plot(xTraj(1:i,1,j),xTraj(1:i,2,j),'k');
            hold on
            plot(xTraj(i,1,j),xTraj(i,2,j),'.k','MarkerSize',20);
        end
    else
        for j = 1:size(xTraj,3);
            plot(xTraj(i-tailLength:i,1,j),xTraj(i-tailLength:i,2,j),'k');
            hold on
            plot(xTraj(i,1,j),xTraj(i,2,j),'.k','MarkerSize',20);
        end        
    end
    axis([xMin-rX*.1 xMax+rX*.1 yMin-rY*.1 yMax+rY*.1]);
    drawnow
end

end

function pair_loop_plot(system_braid)

[pairLoops, loopIndex] = braidlab.lcs.p2ploop(system_braid.n);

n = system_braid.n;

scrsz = get(0,'ScreenSize');

figure('Position',scrsz*.9)

for i = 1:length(loopIndex)
    subplot(n,n,loopIndex(i,1)+(loopIndex(i,2)-1)*n)
    hold on
    pairLoops(i).plot('PunctureColor','g','PunctureSize',.07);
    axis off
    title(['Puncture ' num2str(loopIndex(i,1)) ' to Puncture ' num2str(loopIndex(i,2))]);
end

end

function entangled_puncture_plot(system_braid,nes_combined)

n = system_braid.n;

for i = 1:size(nes_combined,1)
    for j = 1:nes_combined{i,2}
        I = real(nes_combined{i,3}(j));
        J = imag(nes_combined{i,3}(j));
        subplot(n,n,(J-1)*n+I)
        hold on;
        plot(nes_combined{i,1},0*nes_combined{i,1},'.r','MarkerSize',40);
    end
end
        
end

function ips_plot(punctureAssignment)

col = [1 0 0; 0 0 1];

figure; hold on;
for i = 1:length(punctureAssignment)
   plot(i,0,'.','MarkerSize',40,'Color',col(punctureAssignment(i),:)) 
end
axis off

end

function nonGrowingLoop_plot(nonGrowingLoop,punctureAssignment)

hold off
nonGrowingLoop(1).plot('LineColor','r','PunctureSize',.05);
hold on
nonGrowingLoop(2).plot('LineColor','b');


col = [1 0 0; 0 0 1];
for i = 1:length(punctureAssignment)
   plot(i,0,'.','MarkerSize',40,'Color',col(punctureAssignment(i),:)) 
end
axis off



end

