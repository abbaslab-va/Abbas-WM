function DMTS_Tri_Delay_stim_only_SoftCode(byte)
%global visited 

switch byte
    case 1
        SetContinuousLoop(1, 1);
        SetContinuousLoop(2, 1);
    case 2
        SetContinuousLoop(1, 0);
        SetContinuousLoop(2, 0);
end

        
        
        
        
   
        

