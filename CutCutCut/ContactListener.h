#import "Box2D.h"

class ContactListener : public b2ContactListener
{
public:
    void SetNode(id node);
private:
    id _node;
    void BeginContact(b2Contact* contact);
    void EndContact(b2Contact* contact);
};