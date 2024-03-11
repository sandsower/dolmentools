#[derive(Hash)]
pub enum FeatType {
    Minor,
    Major,
    Extraordinary,
    Campaign,
}

pub struct Feat {
    pub feat_type: FeatType,
    pub desc: String,
}

pub struct FeatsXp {
    pub minor: f32,
    pub major: f32,
    pub extraordinary: f32,
    pub campaign: f32,
}

pub const FEATS_XP: FeatsXp = FeatsXp {
    minor: 0.02,
    major: 0.05,
    extraordinary: 0.1,
    campaign: 0.15,
};
