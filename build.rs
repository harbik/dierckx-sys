fn main(){

    let files = 
        ["clocur.f", "cocosp.f", "concon.f", "concur.f", "cualde.f", "curev.f", "curfit.f", "fourco.f", "fpader.f",
        "fpadno.f", "fpadpo.f", "fpback.f", "fpbacp.f", "fpbfout.f", "fpbspl.f", "fpchec.f", "fpched.f", "fpchep.f",
        "fpclos.f", "fpcoco.f", "fpcons.f", "fpcosp.f", "fpcsin.f", "fpcurf.f", "fpcuro.f", "fpdeno.f", "fpdisc.f",
        "fpfrno.f", "fpgivs.f", "fpinst.f", "fpintb.f", "fpknot.f", "fppara.f", "fppocu.f", "fprati.f", "fprota.f",
        "fpseno.f", "insert.f", "parcur.f", "spalde.f", "splder.f", "splint.f", "sproot.f"];
        
        
    cc::Build::new()
        .files(files.iter().map(|&ff|format!("src/netlib-dierckx/{}",ff)))
        .compiler("gfortran")
        .flag("-std=legacy") 
        .flag("-fdefault-real-8") // use f64 for all real values
        .flag("-Wno-maybe-uninitialized") // suppress the maybe-unitialized warnings
        .flag("-O3") // opitmize level 3
        .compile("dierckx")
}

