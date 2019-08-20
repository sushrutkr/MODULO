


%% Set Up and Create Data Matrix D

close all; clc; clear all
 % 1 . Data Preparation
 dt =0.5; t =[0:dt:620]; n_t=length (t); %Time Discretization
 dy =0.01; y=[-1:dy:1]; n_y=length(y); %Space Discretization

% Set the two Waves
W_1=4;      % Womersley 1
Pa_1=20;    % P Amplitude 1
W_2=1;      % Womersley 2
Pa_2=2;     % P Amplitude 2
u_A_r_1=zeros(n_y,n_t); % Solution W_1
u_A_r_2=zeros(n_y,n_t); % Solution W_2

% Add a step-like growth of the large scale mode and a gaussian window to
% the fast scale
T_A_S=50;
T_A_F=max(t)/2;
STEP_S=ones(size(t));
STEP_S(1:floor(n_t/10))=0; STEP_S(end-floor(n_t/10):end)=0;
N_M=50; 

% We construct a smoothed step repeading 5 times a median filter
for i=1:5
    
    STEP_S=conv(STEP_S,ones(1,N_M)/N_M,'same');
    
end

STEP_F=exp(-(t-T_A_F).^2/5000);
%plot(t,STEP_S); hold on; plot(t,STEP_F)

% 2. Initialize Matrices:
 n = [1:1:20]; N=length(n) ;%Modes to include in summation :
 Y_n1=zeros(n_y,N); %Initialize Spatial Basis
 A_n1=zeros(N,N); %Initialize Amplitude Matrix
 T_n1=zeros(n_t,N); %Initialize Temporal Basis
 U_A1=zeros(n_t,n_y);%Initialize PDE solution
 
 Y_n2=zeros(n_y,N); %Initialize Spatial Basis
 A_n2=zeros(N,N); %Initialize Amplitude Matrix
 T_n2=zeros(n_t,N); %Initialize Temporal Basis
 U_A2=zeros(n_t,n_y);%Initialize PDE solution
 

 % 3. Construct Spatial Eigenfunction basis (Fast Scale)
 for i=1:length(n)
     
     N=2*n(i)-1; % odd number in the series
     % Scale 1
     Y_n1(:,i)=cos(N*pi*y/2); % Spatial Eigenfunction basis
     A_n1(i,i) =(16*Pa_1)/(N*pi*sqrt((2*W_1)^4+N^4*pi^4)); % Amplitudes 
     T_n1(:,i)=(-1)^(n(i))*sin(t).*STEP_F; % Temporal coefficients
     % Scale 2
     Y_n2(:,i)=cos(N*pi*y/2); % Spatial Eigenfunction basis
     A_n2(i,i)=(16*Pa_2)/(N*pi*sqrt((2*W_2)^4+N^4*pi^4)); % Amplitudes 
     T_n2(:,i)=(-1)^(n(i))*sin((W_2/W_1)^2*t).*STEP_S; % Temporal coefficients
     
end

 % Assembly Solution
  u_A_r_1=Y_n1*A_n1*T_n1';
  u_A_r_2=Y_n2*A_n2*T_n2';


% Observe the time evolution in the centerline for each
 figure(11)
 hold on
 plot(t,u_A_r_2(floor(n_y/2),:),'ro:')
 plot(t,u_A_r_1(floor(n_y/2),:),'ko:')
 xlabel('Dimensionless Time ','Interpreter','latex','Fontsize',16)
 ylabel('Dimensionless Vel','Interpreter','latex','Fontsize',16)
 title('Centerline Vel Evolution','Interpreter','latex','Fontsize',16)
 
% Assembly the Data Matrix for the test Case
 u_Mb=(1-y.^2).^0.5;%Compute the mean Flow
 u_M=repmat(u_Mb,length(t),1);%Repeat mean to obtain a matrix
 D=u_A_r_1+u_A_r_2+u_M';%Complete analytical Solution
 
% Obs: In constructing D, it is better to avoid windowing problems.
% in this case, noise could be generated by the large scale at the right
% border. To reduce this problem, it is better to limit it so as to have a
% smoother transition. This is equivalent to Hann windowing a signal before
% computing the spectra. The windows used in the scale can be useful to
% this end.


save('Data.mat','D','t','dt','n_t','y','dy','n_y')
 
% subplot(2,1,1)
% imagesc(D)
% subplot(2,1,2)
% plot(D(100,:),'o:')
% return
 
%% Visualize entire evolution (Optional)

filename='Exercise_1.gif';


 for k=1:4:n_t
     
     disp(['time ',num2str(k),' of ',num2str(n_t)])
     HFIG=figure(1);
     HFIG.Units='Normalized';
     HFIG.Position=[0.3 0.3 0.5 0.5];
     subplot(1,2,1)
     plot(y,D(:,k),'ko--','linewidth',2)
     ylim([-2 4])  
     xlim([-1 1])
     set(gca,'Fontname','Palatino Linotype','Fontsize',16,'Box','off','LineWidth',1)
     % Label Information
     xlabel('$\hat{x}$','Interpreter','Latex','fontsize',18)
     ylabel('$\hat{u}$','Interpreter','Latex','fontsize',18)
     set(gcf,'color','w')
 
     subplot(1,2,2)
     imagesc(t,y,D)
     hold on
     plot(ones(size(y))*t(k),y,'r','linewidth',1.5)
     set(gca,'Fontname','Palatino Linotype','Fontsize',16,'Box','off','LineWidth',1)
     % Label Information
     xlabel('$\hat{t}$','Interpreter','Latex','fontsize',18)
     ylabel('$\hat{y}$','Interpreter','Latex','fontsize',18)
     title('$\hat{u}(\hat y,\hat t)$','Interpreter','Latex','fontsize',18)
  
     frame = getframe(1);
     im = frame2im(frame);
     [imind,cm] = rgb2ind(im,256);

      if k == 1
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
      else
          imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime', 0.1);
      end
 
 end
 
 
