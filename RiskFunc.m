function C=RiskFunc(X,e,y)
R = csvread('multi-asset portfolio - Sheet2.csv') ; % Average Returns of all assets
for i=1:length(e)
    if e(i)==0
        X(:,i)=0;
        X(i,:)=0;
        R(i)=0;
    end
end
K=[];                                             
Rnew=[];                         % Average Returns of selected assets
for i=1:length(e)
    if R(i)>0 || R(i)<0
        Rnew=[Rnew,R(i)];
    end
    for j=1:length(e)
        if X(i,j)>0 || X(i,j)<0
            K=[K,X(i,j)];
        end
    end
end
f=ones(sum(e),1);
J=reshape(K,sum(e),sum(e));     % Variance-covariance matrix of selected assests

%% Calculating Risk
objective=@(x) transpose(x)*J*x;
x0=(inv(J)*f)/(transpose(f)*inv(J)*f);
A=-Rnew;
b=-y;
Aeq=ones(1,sum(e));
beq=1;
lb=zeros(length(x0),1);

x = fmincon(objective,x0,A,b,Aeq,beq,lb);

C=objective(x);
end






