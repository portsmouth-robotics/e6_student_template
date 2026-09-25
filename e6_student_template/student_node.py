import rclpy
from rclpy.node import Node


# This is a minimal ROS 2 node to help you get started.
#
# Add your publishers, subscribers, service clients, and robot-control logic
# to this file as you develop your coursework solution.


class E6StudentNode(Node):

    def __init__(self):
        super().__init__('e6_student_node')

        self.get_logger().info('E6 student node started.')

        # Add your ROS 2 setup here.
        #
        # For example:
        #   - service clients for MovJ / MovL
        #   - subscribers to robot-state topics
        #   - publishers if your application requires them


def main(args=None):
    rclpy.init(args=args)

    node = E6StudentNode()

    try:
        rclpy.spin(node)

    except KeyboardInterrupt:
        pass

    finally:
        node.destroy_node()

        if rclpy.ok():
            rclpy.shutdown()


if __name__ == '__main__':
    main()