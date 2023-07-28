function CLAS_EX2_MAGTrain_01032023_FUN(byte)
global BpodSystem
%global visited 
%disp(num2str(byte))
if byte==1
    choose=randsample([2,3],1) 
        if choose==2
            SendBpodSoftCode(2)
            disp('port active =2')
        elseif choose==3
            SendBpodSoftCode(3)
            disp('port active =3')
        end 
elseif byte==2
    choose=randsample([1,3],1) 
        if choose==1
            SendBpodSoftCode(1)
            disp('port active =1')
        elseif choose==3
            SendBpodSoftCode(3)
            disp('port active =3')
        end 
elseif byte==3
    choose=randsample([2,4],1) 
        if choose==2
            SendBpodSoftCode(2)
            disp('port active =2')
        elseif choose==4
            SendBpodSoftCode(4)
            disp('port active =4')
        end 
elseif byte==4
    choose=randsample([3,5],1) 
        if choose==3
            SendBpodSoftCode(3)
            disp('port active =3')
        elseif choose==5
            SendBpodSoftCode(5)
            disp('port active =5')
        end 
elseif byte==5
    choose=randsample([3,4],1) 
        if choose==3
            SendBpodSoftCode(3)
            disp('port active =3')
        elseif choose==4
            SendBpodSoftCode(4)
            disp('port active =4')
        end
        
% elseif byte==6
%     choose=randsample([1:5],1) 
%         if choose==1
%             SendBpodSoftCode(1)
%             disp('port active =1')
%         elseif choose==2
%             SendBpodSoftCode(2)
%             disp('port active =2')
%         elseif choose==3
%             SendBpodSoftCode(3)
%             disp('port active =3')
%         elseif choose==4
%             SendBpodSoftCode(4)
%             disp('port active =4')
%         elseif choose==5
%             SendBpodSoftCode(5)
%             disp('port active =5')   
%         end        
%         
        
else 
    disp('poop')
        
end
end 

        
        
        
        
        
        
        
        
   
        

