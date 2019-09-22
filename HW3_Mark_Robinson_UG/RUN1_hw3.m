clc; close all; clear all;
% set random seed
rng(sum('MarkRobinson'));
% coordinates of the rectangle C1
xa=2; xb=4; ya=1; yb=3;     
% coordinates of the rectangle C2
xa2=2; xb2=7; ya2=3; yb2=5;
hold on; 
% draw rectangle C1
plot([xa xb xb xa xa],[ya ya yb yb ya],'-');
% draw rectangle C2
plot([xa2 xb2 xb2 xa2 xa2],[ya2 ya2 yb2 yb2 ya2],'-');

% generate positive and negative examples
% no of data points
N=100;
% store coordinates for each point
ds=zeros(N,2); 
% store our labels
ls=zeros(N,1);

% create N random variables and generate population
for i=1:N

x=rand(1,1)*8; 
y=rand(1,1)*8;
ds(i,1)=x; 
ds(i,2)=y;
% +ve if falls in the rectangle, -ve otherwise
% within the bounds of rectangle 1
if ((x > xa) && (y > ya) && (y < yb) && ( x < xb)) 
    ls(i)=1;
    plot(x,y,'b+'); 
% within the bounds of rectangle 2
elseif ((x > xa2) && (y > ya2) && (y < yb2) && ( x < xb2)) 
    ls(i)=2; 
    plot(x,y,'k*');
% not within either rectangle (does not belong to a class)
else
    ls(i)=0;
    plot(x,y,'go'); 
end;
end;

hold off;
% get the indices for each class
i1 = find(ls==1);
i2 = find(ls==2);
% calculate the prior for each class: P(Ci)
prior1 = length(i1)/(N);
prior2 = length(i2)/(N);
% get the coordinates for each point in class 1
x1 = ds(i1,1);
y1 = ds(i1,2);
% get the coordinates for each point in class 2
x2 = ds(i2,1);
y2 = ds(i2,2);
% calculate the mean for class 1
m1 = mean([x1 y1]);
% calculate the mean for class 2
m2 = mean([x2 y2]);
% calculate the covariance for class 1
c1 = cov([x1 y1]);
% calculate the covariance for class 2
c2 = cov([x2 y2]);

figure(2)
hold on
plot([xa xb xb xa xa],[ya ya yb yb ya],'-');
% draw rectangle C2
plot([xa2 xb2 xb2 xa2 xa2],[ya2 ya2 yb2 yb2 ya2],'-');
% create new population. this time we will use multivarian distribution to
% figure out which class each point belongs to
error = 0;
count = 0;
for i=1:N
x=rand(1,1)*8; 
y=rand(1,1)*8;
if (((x > xa) && (y > ya) && (y < yb) && ( x < xb)) || ((x > xa2) && (y > ya2) && (y < yb2) && ( x < xb2)))
    count = count + 1;
    % calculate the posterior density for class 2 assuming normal
    % distribution
    pdf1 = mvnpdf([x y],m1,c1);
    % calculate the probability that the point lies in class 1
    p1 = pdf1*prior1;
    % calculate the posterior density for class 2 assuming normal
    % distribution
    pdf2 = mvnpdf([x y],m2,c2)*prior2;
    % calculate the probability that the point lies in class 2
    p2 = pdf2*prior2;
    % calculate posterior
    post1 = p1/p2;
    post2 = p2/p1;
    %linear discriminant functions
    lg1 = -(1/2)*log(abs(c1))-(1/2)*inv(c1)*([x y]-m1).'*([x y]-m1)+log(prior1);
    lg2 = -(1/2)*log(abs(c2))-(1/2)*inv(c2)*([x y]-m2).'*([x y]-m2)+log(prior2);
    % quadratic discriminant functions
    qg1 = -(1/2)*log(abs(c1))-(1/2)*((inv(c1)*[x y].'*[x y])-(2*inv(c1)*[x y].'*m1)+(inv(c1)*m1.'*m1))+log(prior1);
    qg2 = -(1/2)*log(abs(c2))-(1/2)*((inv(c2)*[x y].'*[x y])-(2*inv(c2)*[x y].'*m2)+(inv(c2)*m2.'*m2))+log(prior2);
    % common covariance
    s = (prior1*c1)+(prior2*c2);
    ccg1 = (-1/2)*inv(s)*([x y]-m1).'*([x y]-m1)+log(prior1);
    ccg2 = (-1/2)*inv(s)*([x y]-m2).'*([x y]-m2)+log(prior2);
    
    % point belongs to class 1
    if (lg1 >= lg2)
        plot(x,y,'b+');
        xlim([0 8]);
        ylim([0 8]);
        if ((x > xa2) && (y > ya2) && (y < yb2) && ( x < xb2))
            error = error + 1;
        end
        % point belongs to class 2
    else
        plot(x,y,'k*');
        xlim([0 8]);
        ylim([0 8]);
        if ((x > xa) && (y > ya) && (y < yb) && ( x < xb))
            error = error + 1;
        end
    end
end
end
hold off;
(1-(error/count))*100