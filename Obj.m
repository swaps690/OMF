clc;
clear;
close all;
X= csvread('multi-asset portfolio - var-cov.csv',1,1) ;

%% Problem Definition

nVar=20;

VarSize=[nVar 1];

VarMin=0;
VarMax=1;
%% Parameters of Particle Swarm Optimisation
MaxIt=5;

nPop=15;
w=0.2;        %inertia coefficient
wdamp=0.99;   %damping coefficient
c1=0.5;       %personal acceleration coefficient
c2=0.5;       %Social acceleration coefficient

%% Initialisation

prompt = 'Minimum number of assets?';
kmin = input(prompt);
prompt = 'Maximum number of assets?';
kmax = input(prompt);
prompt = 'Number of assets you want to preassign?';
n = input(prompt);
count = 0;
for count = 1:n
    p(count) = input('Input asset number: ');
end
prompt = 'What is your expected return (in percentage)?';
y = input(prompt)/100;
a=[];
if n > kmin
  a = ones(n,1);
else
  a = ones(kmin,1);
end
b = zeros(nVar-kmax,1);
empty_particle.Position = [];
empty_particle.Velocity = [];
empty_particle.Risk = [];
empty_particle.Best.Position = [];
empty_particle.Best.Risk = [];

particle=repmat(empty_particle,nPop,1);

GlobalBest.Risk = inf;
for i=1:nPop
  c = round(unifrnd(VarMin,VarMax,[(kmax-kmin),1]));
  pool = [a;b;c];
  index = randperm(20);
  for j=1:n
      index=index(index~=p(j));
  end
  index = [p index];
  particle(i).Position=pool(index);
  
  particle(i).Velocity=zeros(VarSize);
  
  particle(i).Risk=RiskFunc(X,particle(i).Position,y);
  
  particle(i).Best.Position=particle(i).Position;
  particle(i).Best.Risk = particle(i).Risk;
  
  %Update globalbest
  if particle(i).Best.Risk < GlobalBest.Risk
      GlobalBest=particle(i).Best;
  end
  
end

BestRisks=zeros(MaxIt,1);

%% Main Loop of PSO

for it=1:MaxIt
    
    for i=1:nPop
        
        % Update Velocity
        particle(i).Velocity=w*particle(i).Velocity...
            +c1*rand(VarSize).*(particle(i).Best.Position - particle(i).Position)...
            +c2*rand(VarSize).*(GlobalBest.Position - particle(i).Position);
        % Update Position
        particle(i).Position = round (particle(i).Position + particle(i).Velocity);
        particle(i).Position(p) = ones(n,1);
        for j=1:nVar
            if particle(i).Position(j)>1
                particle(i).Position(j)=1;
            end
            if particle(i).Position(j)<0
                particle(i).Position(j)=0;
            end
        end
        % Evaluation
        particle(i).Risk = RiskFunc(X,particle(i).Position,y);
        
        % Update Personal Best
        if particle(i).Risk < particle(i).Best.Risk
            particle(i).Best.Position = particle(i).Position;
            particle(i).Best.Risk = particle(i).Risk;
        % Update Global Best
            if particle(i).Best.Risk < GlobalBest.Risk
                GlobalBest=particle(i).Best;
            end
        end


    end
    
    % Store the BestRisk value
    BestRisks(it) = GlobalBest.Risk;
    
    % Display Iteration Information
    disp(['Iteration' num2str(it) ':BestRisks=' num2str(BestRisks(it))]);
    
    w= w * wdamp;
end

%% Results

k=[];
for i=1:nPop
    if particle(i).Risk==GlobalBest.Risk
        x=i;
        break
    end
end
for i=1:20
    if particle(x).Position(i) == 1
        k=[k,i];
    end
end
weights = findw(particle(x).Position,y);
figure;
plot(BestRisks, 'LineWidth' , 2);
xlabel('Iterations');
ylabel('BestRisks');
grid on;
figure;
bar(k,weights,0.5);
xlabel('Assets');
ylabel('Weights');














