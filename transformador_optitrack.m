function MTH = transformador_optitrack(pos_b, or_b, pos_e, or_e)
%FUNCION Transformador optitrack para pasar los puntos del sistema de
%referencia del optitrack al que queremos nosotros

    R_bopti = angle2dcm(or_b(1), or_b(2), or_b(3));
    R_eopti = angle2dcm(or_e(1), or_e(2), or_e(3));

    MTH_Obopti = [R_bopti, pos_b; 0, 0, 0, 1];
    MTH_Oeopti = [R_eopti, pos_e; 0, 0, 0, 1];
    MTH_bopti_eopti = (MTH_Obopti)\MTH_Oeopti;

    v_bopti_eopti = MTH_bopti_eopti(1:3,4);
    v_b_e = [0;0;norm(v_bopti_eopti)];

    v_bopti_eopti = v_bopti_eopti/norm(v_bopti_eopti);
    v_b_e = v_b_e/norm(v_b_e);

    axis = cross(v_b_e, v_bopti_eopti);
    alfa = acos(dot(v_b_e, v_bopti_eopti));

    axis=axis./norm(axis);
    R_bopti_b = Rodrigues(axis./norm(axis), alfa);
    MTH_bopti_b = [R_bopti_b, [0;0;0]; 0,0,0,1];
    %MTH_b_e = [eye(3), [0;0; norm(MTH_bopti_eopti(1:3,4))]; 0, 0, 0, 1];
    %MTH_eopti_e = (MTH_bopti_b\MTH_bopti_eopti)\MTH_b_e;
    MTH = MTH_bopti_b\(eye(4)/MTH_Obopti);
end