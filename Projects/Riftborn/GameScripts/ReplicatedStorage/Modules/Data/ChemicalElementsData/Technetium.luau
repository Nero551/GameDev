local Technetium = {
    Name = "Technetium",
    Symbol = "Tc",
    AtomicNumber = 43,
    AtomicMass = -98,
    RepresentativeMassNumber = 97,
    Protons = 43,
    Electrons = 43,
    NeutronsApprox = 54,
    Category = "Transition",
    Group = "7",
    Period = 5,
    Block = "d",
    StateAt293K = "Solid",
    Density = 11,
    Appearance = "A radioactive, silvery metal that does not occur naturally.",
    Uses = {
        "The gamma-ray emitting technetium-99m (metastable) is widely used for medical diagnostic studies. Several chemical forms are used to image different parts of the body.",
        "Technetium is a remarkable corrosion inhibitor for steel, and adding very small amounts can provide excellent protection. This use is limited to closed systems as technetium is radioactive.",
    },
    ElectronConfiguration = "[Kr] 4d55s2",
    EnergyLevels = {
        2,
        8,
        18,
        13,
        2,
    },
    AtomicRadius = 2.16,
    CovalentRadius = 1.38,
    ElectronAffinity = 53.07,
    Electronegativity = 2.1,
    IonizationEnergies = {
        702.41,
        1472.37,
        2850.18,
    },
    MeltingPointK = 2430,
    BoilingPointK = 4535,
    KeyIsotopes = {},
    Isotopes = {
        {
            Name = "97Tc",
            HalfLife = {
                "4.2 x 106 y",
            },
            Mass = 96.906,
            MassNumber = 97,
            ModeOfDecay = {
                "EC",
            },
        },
        {
            Name = "98Tc",
            HalfLife = {
                "6.6 x 106 y",
            },
            Mass = 97.907,
            MassNumber = 98,
            ModeOfDecay = {
                "beta-",
                "EC",
            },
        },
        {
            Name = "99Tc",
            HalfLife = {
                "2.13 x 105 y",
            },
            Mass = 98.906,
            MassNumber = 99,
            ModeOfDecay = {
                "beta-",
            },
        },
    },
}

return Technetium
