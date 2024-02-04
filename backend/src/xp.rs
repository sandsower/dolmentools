use crate::players::Character;

#[derive(Hash)]
enum FeatType {
    Minor,
    Major,
    Extraordinary,
    Campaign,
}

struct Feat {
    feat_type: FeatType,
    desc: String,
}

struct FeatsXp {
    minor: f32,
    major: f32,
    extraordinary: f32,
    campaign: f32,
}

const FEATS_XP: FeatsXp = FeatsXp {
    minor: 0.02,
    major: 0.05,
    extraordinary: 0.1,
    campaign: 0.15,
};

struct Session {
    characters: Vec<Character>,
    feats: Vec<Feat>,
    xp: f32,
}

struct SessionXpForCharacter {
    name: String,
    xp: f32,
}

/*
Calculate the xp that each character gets
from each feat type in the session
*/
pub fn calculate_xp(session: Session) -> Vec<SessionXpForCharacter> {
    let total_required_xp: f32 = session.characters.iter().map(|c| c.next_level_xp).sum();

    let total_xp_from_feats = session
        .feats
        .iter()
        .fold(0.0, |acc, feat| match feat.feat_type {
            FeatType::Minor => acc + total_required_xp as f32 * FEATS_XP.minor,
            FeatType::Major => acc + total_required_xp as f32 * FEATS_XP.major,
            FeatType::Extraordinary => acc + total_required_xp as f32 * FEATS_XP.extraordinary,
            FeatType::Campaign => acc + total_required_xp as f32 * FEATS_XP.campaign,
        });

    return session
        .characters
        .iter()
        .map(|c| {
            let xp_from_feats = match c.extra_xp_modifier {
                x if x > 0.0 => total_xp_from_feats + (total_xp_from_feats * c.extra_xp_modifier),
                _ => total_xp_from_feats,
            };
            SessionXpForCharacter {
                name: c.name.clone(),
                xp: (xp_from_feats + session.xp).floor(),
            }
        })
        .collect();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_calculate_xp() {
        let feats = vec![
            Feat {
                feat_type: FeatType::Minor,
                desc: "went to a dungeon".to_string(),
            },
            Feat {
                feat_type: FeatType::Minor,
                desc: "went to a dungeon".to_string(),
            },
            Feat {
                feat_type: FeatType::Major,
                desc: "went to a dungeon".to_string(),
            },
        ];
        let session = Session {
            characters: vec![
                Character {
                    name: "B".to_string(),
                    next_level_xp: 100.0,
                    extra_xp_modifier: 0.2,
                    current_xp: 0.0,
                    level: 1,
                    class: "fighter".to_string(),
                },
                Character {
                    name: "B".to_string(),
                    next_level_xp: 100.0,
                    extra_xp_modifier: 0.2,
                    current_xp: 0.0,
                    level: 1,
                    class: "fighter".to_string(),
                },
                Character {
                    name: "C".to_string(),
                    next_level_xp: 100.0,
                    current_xp: 0.0,
                    level: 1,
                    class: "fighter".to_string(),
                    extra_xp_modifier: 0.0,
                },
            ],
            feats,
            xp: 100.0,
        };

        let session_xp: Vec<SessionXpForCharacter> = calculate_xp(session);
        assert_eq!(session_xp.len(), 3);
        assert_eq!(session_xp[0].name, "A");
        assert_eq!(session_xp[0].xp, 129.0);
        assert_eq!(session_xp[1].name, "B");
        assert_eq!(session_xp[1].xp, 132.0);
        assert_eq!(session_xp[2].name, "C");
        assert_eq!(session_xp[2].xp, 127.0);
    }
}
