//
//  Constants.h
//  dsrunner
//
//  Created by Chen Zeyu on 13-3-30.
//  Copyright (c) 2013年 nus.cs3217. All rights reserved.
//
typedef enum {
    GameModelRunner,
    GameModelEnemy,
    GameModelProjectile,
    GameModelDestination,
    GameModelGround,
    GameModelBlockPath,
    GameModelReflectPath,
    GameModelRedInk,
    GameModelGreenInk,
    GameModelGift
} GameModelType;

//for SingleView Controller
#define OBJECT_MIN_Y -200
#define RUNNER_BODY_WIDTH 15
#define RUNNER_BODY_HEIGHT 48
#define RUNNER_VIEW_WIDTH 40
#define RUNNER_VIEW_HEIGHT 60
#define RUNNER_VIEW_OFFSET CGPointMake(0, 7)
#define RUNNER_IMAGE_VIEW @"frame-1.png"
#define EMPTYGROUND_WIDTH 0
#define EMPTYGROUND_HEIGHT 0
#define NORMALGROUND_WIDTH 157
#define NORMALGROUND_HEIGHT 157
#define HIGHGROUND_WIDTH 200
#define HIGHGROUND_HEIGHT 200
#define SUPERHIGHGROUND_WIDTH 250
#define SUPERHIGHGROUND_HEIGHT 250
#define RUNNER_WALK_DURATION 0.4
#define RED_INK_POS_X 355
#define RED_INK_POS_Y 10
#define INK_WIDTH 263
#define INK_HEIGHT 40
#define RED_INK_STAND_POS_X 305
#define RED_INK_STAND_POX_Y 10
#define GREEN_INK_POS_X 355
#define GREEN_INK_POS_Y 55
#define GREEN_INK_STAND_POS_X 305
#define GREEN_INK_STAND_POX_Y 55
#define INK_STAND_WIDTH 40
#define INK_STAND_HEIGHT 40
#define TICK_POS_X 250
#define TICK_POS_Y_GREEN 55
#define TICK_POS_Y_RED 10
#define TICK_WIDTH 40
#define TICK_HEIGHT 40
#define ENEMY_WIDTH 90
#define ENEMY_HEIGHT 60
#define ENEMY_VELOCITY 50
#define PROJECTILE_GENERATION_INTERVAL 240
#define PROJECTILE_VELOCITY 100
#define PROJECTILE_WIDTH 10
#define PROJECTILE_HEIGHT 10

#define FPS 30.0
#define GRAVITY 300
#define PATH_LIFESPAN 150
#define BOARD_UNIT_OFFSET 700
#define MOVE_BOARD_THRESHOLD 800
#define BOARD_HEIGHT 668
#define PATH_THICKNESS 5
#define MIN_LINE_LEN 5
#define MIN_LINE_LEN_END 1
#define RED_INK 0
#define GREEN_INK 1
#define LEFT_BOARDER_WIDTH 10
#define KINDS_OF_INK 2
#define INK_INCREASEMENT 100
#define INK_INC_INTERVAL 3

#define INFINITE_LOOP -1
#define RUNNER_VOLUMN 0.1
#define RUNNER_WALKING_ANIME_DURATION 0.8
#define DEVIATION 5

#define WIDTH_STRING @"width"
#define HEIGHT_STRING @"height"
#define X_STRING @"x"
#define INK_STRING @"ink"
#define SPEED_STRING @"speed"
#define Y_STRING @"y"

#define ENEMY_NAME @"enemy"
#define GROUND_NAME @"ground"
#define DESTINATION_NAME @"destination"
#define LEVEL_NAME @"level"
#define BACKGROUND_MUSIC @"background"
#define CHALK_MUSIC @"chalk"
#define WARNING_MUSIC @"warning"
#define PLAYER_BACKGROUND_MUSIC @"PlayerBackground"
#define RUNNING_MUSIC @"running"
#define WAV_FORMAT @"wav"
#define MP3_FORMAT @"mp3"
#define SINGLE_MODE_IDENTIFIER @"single"
#define HOMESCREEN_IDENTIFIER @"home"
#define MULTI_MODE_IDENTIFIER @"multi"
#define SUN_DESTINATION @"sunDestination"

// Images
#define REDINK_IMAGE @"redink.png"
#define BRICK_GROUND_IMAGE @"brickground.png"
#define REDINK_STAND_IMAGE @"redinkstand.png"
#define SUN_DESTINATION @"sunDestination"
#define GREENINK_IMG @"greenink.png"
#define GREENINK_STAND_IMG @"greeninkstand.png"
#define TICK_IMG @"ticksmall.png"
#define SMALL_BRICK_IMAGE @"smallBrick.jpg"
#define ENEMY_IMAGE @"horse-1.png"
#define GREENINK_IMAGE @"greenink.png"
#define GREENINK_STAND_IMAGE @"greeninkstand.png"
#define TICK_IMAGE @"ticksmall.png"
#define RED_BRUSH_IMAGE @"redbrush.png"
#define GREEN_BRUSH_IMAGE @"greenbrush.png"
#define DESTINATION_IMAGE @"sunDestination.png"
//FOR BrushPattern and PathView
#define PATTERN_WIDTH 289
#define PATTERN_HEIGHT 29
#define PATTERN_ORIGIN_X 0
#define PATTERN_ORIGIN_Y 0
#define R 242.0/255
#define G 78.0/255
#define B 42.0/255
#define ALPHA 1.0
#define SHADOW_X_OFFSET 1
#define SHADOW_Y_OFFSET -1
#define SHADOW_WIDTH 2

//FOR CreditsViewController




//WORLD Editor
#define DEFAULT_INK_AMOUNT 200
#define DEFAULT_RUNNER_SPEED 100
#define DEFAULT_RUNNER_X 20
#define DEFAULT_RUNNER_Y 230
#define LEAVE_WITHOUT_SAVING @"Leave without saving?"
#define SEGUE_FROM_WE_TO_MP @"WETMP"
#define CONFIRM_BUTTON @"OK"
#define SAVE_TITLE @"SAVE"
#define SAVE_MESSAGE @"Enter level name" 
#define CANCEL_BUTTON @"Cancel"
#define CONFIRM_SAVE @"save for me"
#define CANCEL_SAVE @"I just want to go!"
#define CHANGES_NOT_SAVED @"Changes Not Saved"
#define LEVEL_FORMAT @"user_%@.xml"
#define SAVE_ABORT @"Saving Aborted"
#define GROUND_XML_FORMAT @"<ground width='%d' height='%d' x='%d' y='%d'/>\n"
#define ENEMY_XML_FORMAT @"<enemy width='110' height='90' x='%d' y='%d'/>\n"
#define DESTINATION_XML_FORMAT @"<destination width='%d' height='%d' x='%d' y='%d'/>\n"
#define LEVEL_START_XML_FORMAT @"<level width='%d' ink='%d' speed='%d' x='%d' y='%d'>\n"
#define LEVEL_END_XML_FORMAT @"</level>\n"
#define DUMMY_DESTINATION @"<destination width='-1' height='-1' x='2000' y='300'/>\n"
#define DUMMY_ENEMY @"<enemy width='-1' height='-1' x='2000' y='300'/>\n"
#define DUMMY_GROUND @"<ground width='-1' height='-1' x='2000' y='300'/>\n"
#define GROUND_PALETTE_POSITION_X 220
#define GROUND_PALETTE_POSITION_Y 10
#define ENEMY_PALETTE_POSITION_Y -10
#define ENEMY_PALETTE_POSITION_X 370

#define makePaletteSize CGSizeMake(80,110)
#define makeGameAreaSize CGSizeMake(4900,668)

#define GAME_AREA_HEIGHT 668

//FOR LEVEL SELECTOR

#define SELECT_VIEW_HEIGHT 633
#define SELECT_VIEW_WIDTH 1024
#define DEFAULT_BUTTON_POSITION CGRectMake(1125, 45, 200, 200)
#define X_THRESHOLD 700
#define INCREMENT 301
#define INCREMENT_PAGE 402
#define Y_THRESHOLD 300
#define BUTTON_LENTH 200
#define USER_LEVEL_BUTTON_TAG 111
#define USER_LEVEL_PREFIX @"user_"
#define USER_LEVEL_SEPARATOR @"_"
#define DEFAULT_LEVEL_SEPARATOR @" "
#define DEFAULT_LEVEL_FORMAT @"level%@.xml"

//FOR SINGLEVIEW
#define HANDLE_COLLISION_METHOD_FORMAT @"handle%@Collision:with:"
#define SHOULD_COLLIDE_METHOD_FORMAT @"should%@Collide:with:"



typedef struct{
    int type;
    CGSize size;
    CGPoint center;
    int orientation;
} UnitData;

typedef struct{
    int type;
    int mapSeed;
} MapData;

typedef struct{
    int type;
    int seed;
} GiftData;

typedef enum {
    GAMEDATA_MAP,
    GAMEDATA_FOREGROUND,
    GAMEDATA_WIN,
    GAMEDATA_GIFT,
    GAMEDATA_DIE
} GAMEDATA;

#define SCREEN_WIDTH 1024
#define MULTIVIEW_RATIO 0.3125

typedef enum {
    GIFTTYPE_ADDENEMY = 0,
    GIFTTYPE_STUCK = 1,
    GIFTTYPE_BLINK = 2,
    GIFTTYPE_NOMANA = 3,
    GIFTTYPE_UPSIDEDOWN = 4
} GIFTTYPE;

