pub struct Character {
    pub name: String,
    pub class: String,
    pub level: u8,
    pub current_xp: f32,
    pub next_level_xp: f32, // difference between current and next level in xp
    pub extra_xp_modifier: f32,
}
