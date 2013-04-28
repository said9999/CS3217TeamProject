//
//  EngineConstants.h
//

#define EPS 1e-3
#define ITERATIONS 3
#define LIFT_LINE_SLOPE_THRESHOLD 1.5
#define LIFT_LINE_Y_THRESHOLD 5
#define COLLISION_ERROR 3

#define HANDLE_COLLISION_NOTIFICATION @"handle_collision"
#define SHOULE_COLLIDE_NOTIFICATION @"should_collide"

// Bodies
#define Body_RECTANGLE @"Rectangle"

// Identifiers
#define COLLISION_NAME_FORMAT @"%@%@Collision"

// RTREE
#define RTREE_BRANCH_FACTOR 10
#define RTREE_FILL_FACTOR 0.7