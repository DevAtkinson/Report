function [Fout,Gout]=analyticalspeckleContinuous7(stepsize,specsize,fux,fuy,fillfactor,numpoints,lims) 
    % This function is based on the methods used in the paper: 'Performance of sub-pixel registration algorithms in digital image correlation' using analytical formulas for speckles. And the code here has been adapted from code written by Matthew Molteno

    % create a grid of points which corresponding to the centroids of pixels
    x=lims(1):stepsize:lims(2);
    y=lims(4):-stepsize:lims(3);
    [X,Y]=meshgrid(x,y);
    [ysize,xsize]=size(X);
    % reshape X and Y to column vectors for the purpose of vectorisation (for GPU)
    X=reshape(X,[ysize*xsize,1]);
    Y=reshape(Y,[ysize*xsize,1]);

    % for super sampling create a grid of points that fall within the CCD array elements fillfactor area (xgrid1 and ygrid1) 
    if numpoints>1
        % determine the stepsize for this grid of points
        xdist=(stepsize./2.*(1 - fillfactor./2) - ( - stepsize./2.*(1 - fillfactor./2)))/(numpoints-1);
        ydist=(stepsize./2.*(1 - fillfactor./2) - ( - stepsize./2.*(1 - fillfactor./2)))/(numpoints-1);
        % use the stepsize to define the grid of points
        xgrid1=( - stepsize./2.*(1 - fillfactor./2)):xdist:( stepsize./2.*(1 - fillfactor./2));
        ygrid1=( - stepsize./2.*(1 - fillfactor./2)):ydist:( stepsize./2.*(1 - fillfactor./2));
    else %if numpoints is 1 (no super sampling - to reduce computation time)
        xdist=0;
        ydist=0;
        xgrid1=0;
        ygrid1=0;
    end
    [xgrid2,ygrid2]=meshgrid(xgrid1,ygrid1);
    % jitter the grid of points so that the locations are somewhat random
    xgrid3=xgrid2 + (gpuArray.rand(numpoints,numpoints) - 0.5).*xdist;
    ygrid3=ygrid2 + (gpuArray.rand(numpoints,numpoints) - 0.5).*ydist;

    % reshape xgrid3 and ygrid3 to be row vectors and pass them to the GPU
    xxgrid=gpuArray(reshape(xgrid3,[1,numpoints*numpoints]));
    yygrid=gpuArray(reshape(ygrid3,[1,numpoints*numpoints]));
    
    % adjust specsize from units of pixels to the units used by the displacement function
    specsize=(specsize(:)*(lims(2)-lims(1))/xsize)/2;
    % determine the speckle locations and size
    posx=rand(1,length(specsize))*(lims(2)-lims(1)) + lims(1);
    posy=rand(1,length(specsize))*(lims(4)-lims(3)) + lims(3);
    specamp=rand(length(specsize),1)/2+0.5; % speckle amplitude lies between 0.5 and 1

    % this function is used to adjust the amplitude of the sin function based on the number of repeated sine curves that fall within the range [0,2*pi] (repetitions per revolution)
    T=@(x) 0.2275+2.1.*exp(-x);
    % this value adjusts the portion of the speckle radius which is dependent on the sine function
    amp=2
    
    % save speckle information in the form that it is needed 
    for k=1:length(specsize)
        a(1,k)=rand([1,1]).*2.*pi;              % define a random phase shift
        b(1,k)=randi([1,5],[1,1]);              % define a random frequency of the sine function per revolution
        c(1,k)=(specsize(k)/amp).*(T(b(1,k)));  % define an amplitude of the sine function
        d(1,k)=specsize(k);                     % define the base radius which the sine function changes
        Xk(1,k)=posx(k);                        % define the x position of the speckle
        Yk(1,k)=posy(k);                        % define the y position of the speckle
        I0(k,1)=specamp(k);                     % define the light intensity at the centre of the speckle
    end

    % Determine how many elements can be processed at once on the GPU (due to ram limitations). The number 44567000 is specific to the computer used during the project (4 GB of VRAM).
    div=(xsize.*ysize.*max(size(specsize))*numpoints*numpoints)/(44567000);
    numOfPixels=floor(ysize*xsize/ceil(div));
    
    H=fspecial('average',[numpoints,numpoints]); % matrix to average the light intensities for one pixel
    H=reshape(H,[1,numpoints,numpoints]); %reshape into a row vector
    HH=repmat(H,[numOfPixels,1,1]);  % create a larger matrix of repeated rows that is equivalent in size to the number of elements to be generated
    
    Fout=zeros([ysize*xsize,1]);
    Gout=zeros([ysize*xsize,1]);

    for imageCount=1:2
        count=0;
        Xgrid=gpuArray.zeros([numOfPixels,numpoints,numpoints]);
        Ygrid=Xgrid;
        for k=1:ceil(div)
            % determine the range of locations to save the pixel light intensity values to
            begin=1+count*numOfPixels;
            ending=(count+1)*numOfPixels;
            ending2=numOfPixels;
            % for the last iteration of k adjust the range of locations so that they do not go beyond the last pixel
            if ending>ysize*xsize
                ending=ysize*xsize;
                ending2=ysize*xsize-count*numOfPixels;
            end
            
            if imageCount==1 %if this is the reference image
                Xin=gpuArray(X(begin:ending))+xxgrid;
                Yin=gpuArray(Y(begin:ending))+yygrid;
            else % otherwise it is the deformed image (apply displacement function)
                Xin=gpuArray(X(begin:ending))-fux(X(begin:ending),Y(begin:ending))+xxgrid;
                Yin=gpuArray(Y(begin:ending))-fuy(X(begin:ending),Y(begin:ending))+yygrid;
            end

            [rrr1,rrr2]=size(Xin);
            % reshape the grid of points into a column vector for the purpose of matrix multiplication
            Xgrid=gpuArray(reshape(Xin,[rrr1*rrr2,1]));
            Ygrid=gpuArray(reshape(Yin,[rrr1*rrr2,1]));
            clear Xin Yin
            % determine the distance between the points under consideration and the speckle locations
            X1=Xgrid-Xk;
            Y1=Ygrid-Yk;
            clear Xgrid Ygrid
            % determine the angle from the centre of each speckle to each grid point to be evaluated
            angles=atan2(Y1,X1);
            % manipulate the angle by applying a predefined phase shift (b) and multiplying by c to change the frequency
            sinin=(angles+a).*b;
            clear angles
            % calculate the sin of the angles times its amplitude plus its shift to get the radius of the speckle in this specific direction
            sins1=sin(sinin).*c+d;
            clear sinin
            % square the radius of the speckle
            sins=sins1.^2;
            clear sins1
            % determine the distance squared between the speckle centre and the point under consideration
            X2=X1.^2;
            clear X1
            Y2=Y1.^2;
            clear Y1
            M=X2+Y2;
            clear X2 Y2
            % taking the exponent of the negative distance squared between the speckle centre and the point under consideration over the squared radius of the speckle. This function ensures that the light intensity for each speckle tapers off as points are analysed further and further from its centre
            speckleContribution=exp(-(M)./(sins));
            clear sins M
            Image_temp=speckleContribution*(I0);
            clear speckleContribution
            % reshape the points so that each row contains the supersampled light intensity values for each pixel
            Image_temp2=reshape(Image_temp,[rrr1,rrr2]);
            clear Image_temp
            % keep only the rows which are valid
            Image_sampled=Image_temp2(1:ending2,:);
            clear Image_temp2
            % use the guassian weighted average to determine the light intensity value for a pixel from its supersampled values
            Image_out_temp=sum(Image_sampled.*HH(1:ending2,:),2);
            clear Image_sampled
            % collect the pixel elements from the GPU and save them to the image matrix (on the GPU - in normal RAM)
            if imageCount==1
                Fout(begin:ending)=gather(Image_out_temp);
            else
                Gout(begin:ending)=gather(Image_out_temp);
            end
            clear Image_out_temp
            count=count+1;
        end
    end
    % reshape the column of pixels into a matrix
    Fout=reshape(Fout,[ysize,xsize]);
    Gout=reshape(Gout,[ysize,xsize]);
    % perform quantization on the light intensity values
    Fout=quantization(Fout,12);
    Gout=quantization(Gout,12);
end

function out=quantization(im,bit)
    % quantization to simulate the analogue to digital conversion of the CCD array
    num_levels=2^bit;
    stepsize=1/num_levels;
    bias=stepsize/2;
    values=0:stepsize:1;
    levels=values(2:end);
    out=imquantize(im,levels,values);
end